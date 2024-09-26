contract;
 
use std::{
    asset::{
        mint_to,
        transfer,
    },
    call_frames::msg_asset_id,
    constants::DEFAULT_SUB_ID,
    context::msg_amount,
    hash::{
        Hash,
        sha256,
    },
    storage::storage_string::*,
    string::String,
};



 
use standards::{src20::SRC20, src6::{Deposit, SRC6, Withdraw}};

abi LiquidityPool {
    #[storage(read, write), payable]
    fn lockAndBorrow(recipient: Address, interest_rate: u64, borrow_duration: u64);
    
    fn WithdrawAndRefund(recipient: Address);
}
const BASE_ASSET: AssetId = AssetId::from(0x9ae5b658754e096e4d681c548daf46354495a437cc61492599e33fc64dcdc30c);
 
pub struct VaultInfo {
    /// Amount of assets currently managed by this vault
    managed_assets: u64,
    /// The vault_sub_id of this vault.
    vault_sub_id: SubId,
    /// The asset being managed by this vault
    asset: AssetId,
}

pub struct BorrowerInfo {

    locked_assets: u64,

    sub_id: SubId,

    asset: AssetId,

    minted_amount: u64,

    interest_rate:u64,

    borrow_timestamp: u64,

    borrow_duration: u64,
}

struct BorrowLog {
    recipient: Address,
    locked_assets: u64,
    minted_amount: u64,
    interest_rate: u64,
    borrow_duration: u64,
}

 
storage {
    /// Vault share AssetId -> VaultInfo.
    vault_info: StorageMap<AssetId, VaultInfo> = StorageMap {},
    /// Number of different assets managed by this contract.
    total_assets: u64 = 0,
    /// Total supply of shares.
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
    /// Asset name.
    name: StorageMap<AssetId, StorageString> = StorageMap {},
    /// Asset symbol.
    symbol: StorageMap<AssetId, StorageString> = StorageMap {},
    /// Asset decimals.
    decimals: StorageMap<AssetId, u8> = StorageMap {},
    
    balance: u64 = 0,
    
    borrower_info_map: StorageMap<Address, BorrowerInfo> = StorageMap {},

}
 
 
impl LiquidityPool for Contract {


#[storage(read, write), payable]
fn lockAndBorrow(recipient: Address, interest_rate: u64, borrow_duration: u64) {
    require(msg_asset_id() == BASE_ASSET, "Invalid asset ID");
    require(msg_amount() > 0, "Amount must be greater than zero");

    // Check if the recipient already has an active loan
    if let Some(existing_loan) = storage.borrower_info_map.get(recipient).try_read() {
        require(existing_loan.locked_assets == 0, "Active loan exists");
    }

    if msg_asset_id() == AssetId::base() {
        // If we received the base asset then keep track of the balance.
        // Otherwise, we're receiving other native assets and don't care
        // about our balance of coins.
        storage.balance.write(storage.balance.read() + msg_amount());
    }

    // Mint two times the amount.
    let amount_to_mint = msg_amount() * 2;

    // Create the BorrowerInfo struct
    let borrower_info = BorrowerInfo {
        locked_assets: msg_amount(),
        sub_id: DEFAULT_SUB_ID,
        asset: msg_asset_id(),
        minted_amount: amount_to_mint,
        interest_rate,
        borrow_timestamp: 90,
        borrow_duration,
    };

    // Insert the BorrowerInfo into the StorageMap
    storage.borrower_info_map.insert(recipient, borrower_info);
    
    // Mint some LP assets based upon the amount of the base asset.
    mint_to(Identity::Address(recipient), DEFAULT_SUB_ID, amount_to_mint);

    // Log the borrow information
    let borrow_log = BorrowLog {
        recipient,
        locked_assets: borrower_info.locked_assets,
        minted_amount: borrower_info.minted_amount,
        interest_rate: borrower_info.interest_rate,
        borrow_duration: borrower_info.borrow_duration,
    };

    log(borrow_log);
}


 
    fn WithdrawAndRefund(recipient: Address) {
        let asset_id = AssetId::default();
        assert(msg_asset_id() == asset_id);
        assert(msg_amount() > 0);
 
        // Amount to withdraw.
        let amount_to_transfer = msg_amount() / 2;
 
        // Transfer base asset to recipient.
        transfer(Identity::Address(recipient), BASE_ASSET, amount_to_transfer);
    }
}
 
 
 
impl SRC6 for Contract {
    #[payable]
    #[storage(read, write)]
    fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64 {
        let asset_amount = msg_amount();
        let underlying_asset = msg_asset_id();
 
        require(underlying_asset == AssetId::base(), "INVALID_ASSET_ID");
        let (shares, share_asset, share_asset_vault_sub_id) = preview_deposit(underlying_asset, vault_sub_id, asset_amount);
        require(asset_amount != 0, "ZERO_ASSETS");
 
        _mint(receiver, share_asset, share_asset_vault_sub_id, shares);
 
        let mut vault_info = match storage.vault_info.get(share_asset).try_read() {
            Some(vault_info) => vault_info,
            None => VaultInfo {
                managed_assets: 0,
                vault_sub_id,
                asset: underlying_asset,
            },
        };
        vault_info.managed_assets = vault_info.managed_assets + asset_amount;
        storage.vault_info.insert(share_asset, vault_info);
 
        log(Deposit {
            caller: msg_sender().unwrap(),
            receiver: receiver,
            underlying_asset,
            vault_sub_id: vault_sub_id,
            deposited_amount: asset_amount,
            minted_shares: shares,
        });
 
        shares
    }
 
    #[payable]
    #[storage(read, write)]
    fn withdraw(
        receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
    ) -> u64 {
        let shares = msg_amount();
        require(shares != 0, "ZERO_SHARES");
 
        let (share_asset_id, share_asset_vault_sub_id) = vault_asset_id(underlying_asset, vault_sub_id);
 
        require(msg_asset_id() == share_asset_id, "INVALID_ASSET_ID");
        let assets = preview_withdraw(share_asset_id, shares);
 
        let mut vault_info = storage.vault_info.get(share_asset_id).read();
        vault_info.managed_assets = vault_info.managed_assets - shares;
        storage.vault_info.insert(share_asset_id, vault_info);
 
        _burn(share_asset_id, share_asset_vault_sub_id, shares);
 
        transfer(receiver, underlying_asset, assets);
 
        log(Withdraw {
            caller: msg_sender().unwrap(),
            receiver: receiver,
            underlying_asset,
            vault_sub_id: vault_sub_id,
            withdrawn_amount: assets,
            burned_shares: shares,
        });
 
        assets
    }
 
    #[storage(read)]
    fn managed_assets(underlying_asset: AssetId, vault_sub_id: SubId) -> u64 {
        if underlying_asset == AssetId::base() {
            let vault_share_asset = vault_asset_id(underlying_asset, vault_sub_id).0;
            // In this implementation managed_assets and max_withdrawable are the same. However in case of lending out of assets, managed_assets should be greater than max_withdrawable.
            managed_assets(vault_share_asset)
        } else {
            0
        }
    } 
 
    #[storage(read)]
    fn max_depositable(
        receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
    ) -> Option<u64> {
        if underlying_asset == AssetId::base() {
            // This is the max value of u64 minus the current managed_assets. Ensures that the sum will always be lower than u64::MAX.
            Some(u64::max() - managed_assets(underlying_asset))
        } else {
            None
        }
    }
 
    #[storage(read)]
    fn max_withdrawable(underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64> {
        if underlying_asset == AssetId::base() {
            // In this implementation total_assets and max_withdrawable are the same. However in case of lending out of assets, total_assets should be greater than max_withdrawable.
            Some(managed_assets(underlying_asset))
        } else {
            None
        }
    }
}
 
impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        storage.total_assets.try_read().unwrap_or(0)
    }
 
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        storage.total_supply.get(asset).try_read()
    }
 
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        storage.name.get(asset).read_slice()
    }
 
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        storage.symbol.get(asset).read_slice()
    }
 
    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        storage.decimals.get(asset).try_read()
    }
}
 
/// Returns the vault shares assetid and subid for the given assets assetid and the vaults sub id
fn vault_asset_id(underlying_asset: AssetId, vault_sub_id: SubId) -> (AssetId, SubId) {
    let share_asset_vault_sub_id = sha256((underlying_asset, vault_sub_id));
    let share_asset_id = AssetId::new(ContractId::this(), share_asset_vault_sub_id);
    (share_asset_id, share_asset_vault_sub_id)
}
 
#[storage(read)]
fn managed_assets(share_asset: AssetId) -> u64 {
    match storage.vault_info.get(share_asset).try_read() {
        Some(vault_info) => vault_info.managed_assets,
        None => 0,
    }
}
 
#[storage(read)]
fn preview_deposit(
    underlying_asset: AssetId,
    vault_sub_id: SubId,
    assets: u64,
) -> (u64, AssetId, SubId) {
    let (share_asset_id, share_asset_vault_sub_id) = vault_asset_id(underlying_asset, vault_sub_id);
 
    let shares_supply = storage.total_supply.get(share_asset_id).try_read().unwrap_or(0);
    if shares_supply == 0 {
        (assets, share_asset_id, share_asset_vault_sub_id)
    } else {
        (
            assets * shares_supply / managed_assets(share_asset_id),
            share_asset_id,
            share_asset_vault_sub_id,
        )
    }
}
 
#[storage(read)]
fn preview_withdraw(share_asset_id: AssetId, shares: u64) -> u64 {
    let supply = storage.total_supply.get(share_asset_id).read();
    if supply == shares {
        managed_assets(share_asset_id)
    } else {
        shares * (managed_assets(share_asset_id) / supply)
    }
}
 
#[storage(read, write)]
pub fn _mint(
    recipient: Identity,
    asset_id: AssetId,
    vault_sub_id: SubId,
    amount: u64,
) {

    let supply = storage.total_supply.get(asset_id).try_read();
    // Only increment the number of assets minted by this contract if it hasn't been minted before.
    if supply.is_none() {
        storage.total_assets.write(storage.total_assets.read() + 1);
    }
    let current_supply = supply.unwrap_or(0);
    storage
        .total_supply
        .insert(asset_id, current_supply + amount);
    mint_to(recipient, vault_sub_id, amount);
}
 
#[storage(read, write)]
pub fn _burn(asset_id: AssetId, vault_sub_id: SubId, amount: u64) {
    use std::{asset::burn, context::this_balance};
 
    require(
        this_balance(asset_id) >= amount,
        "BurnError::NotEnoughCoins",
    );
    // If we pass the check above, we can assume it is safe to unwrap.
    let supply = storage.total_supply.get(asset_id).try_read().unwrap();
    storage.total_supply.insert(asset_id, supply - amount);
    burn(vault_sub_id, amount);
}
 