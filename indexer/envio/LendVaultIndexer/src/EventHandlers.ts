import {
  LendVault,
} from "generated";

LendVault.Withdraw.handler(async ({ event, context }) => {
  context.VaultWidrawal.set({
    id: event.params.receiver.payload.bits,
    vaultId: event.params.vault_sub_id,
    assetId: event.params.underlying_asset.bits,
    withdrawnAmount: event.params.withdrawn_amount,
    burnedShares: event.params.burned_shares,
  });
});

LendVault.BorrowLog.handler(async ({ event, context }) => {
  context.BorrowerLog.set({
    id: event.params.recipient.bits,
    collateralLocked: event.params.locked_assets,
    tokenMinted: event.params.minted_amount,
    interest: event.params.interest_rate,
    duration: event.params.borrow_duration,
  });
});

LendVault.LoanReturned.handler(async ({ event, context }) => {
  context.ReturnLoanDetails.set({
    id: event.params.recipient.bits,
    returnedAmount: event.params.returned_amount,
    interest: event.params.interest_paid,
    duration: event.params.timestamp,
  });
});

LendVault.Deposit.handler(async ({ event, context }) => {
  context.VaultDeposit.set({
    id: event.params.receiver.payload.bits,
    vaultId: event.params.vault_sub_id,
    assetId: event.params.underlying_asset.bits,
    collateralLocked: event.params.deposited_amount,
    tokenMinted: event.params.minted_shares,
  });
});