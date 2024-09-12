/* Autogenerated file. Do not edit manually. */

/* eslint-disable max-classes-per-file */
/* eslint-disable @typescript-eslint/no-unused-vars */
/* eslint-disable @typescript-eslint/consistent-type-imports */

/*
  Fuels version: 0.94.5
*/

import { Contract, Interface } from "fuels";
import type {
  Provider,
  Account,
  StorageSlot,
  AbstractAddress,
  BigNumberish,
  BN,
  FunctionFragment,
  InvokeFunction,
} from 'fuels';

export type AddressInput = { bits: string };
export type AddressOutput = AddressInput;

const abi = {
  "programType": "contract",
  "specVersion": "1",
  "encodingVersion": "1",
  "concreteTypes": [
    {
      "type": "()",
      "concreteTypeId": "2e38e77b22c314a449e91fafed92a43826ac6aa403ae6a8acb6cf58239fbaf5d"
    },
    {
      "type": "struct std::address::Address",
      "concreteTypeId": "f597b637c3b0f588fb8d7086c6f4735caa3122b85f0423b82e489f9bb58e2308",
      "metadataTypeId": 1
    },
    {
      "type": "u64",
      "concreteTypeId": "1506e6f44c1d6291cdf46395a8e573276a4fa79e8ace3fc891e092ef32d1b0a0"
    }
  ],
  "metadataTypes": [
    {
      "type": "b256",
      "metadataTypeId": 0
    },
    {
      "type": "struct std::address::Address",
      "metadataTypeId": 1,
      "components": [
        {
          "name": "bits",
          "typeId": 0
        }
      ]
    }
  ],
  "functions": [
    {
      "inputs": [],
      "name": "receive_funds",
      "output": "2e38e77b22c314a449e91fafed92a43826ac6aa403ae6a8acb6cf58239fbaf5d",
      "attributes": [
        {
          "name": "storage",
          "arguments": [
            "read",
            "write"
          ]
        },
        {
          "name": "payable",
          "arguments": []
        }
      ]
    },
    {
      "inputs": [
        {
          "name": "amount_to_send",
          "concreteTypeId": "1506e6f44c1d6291cdf46395a8e573276a4fa79e8ace3fc891e092ef32d1b0a0"
        },
        {
          "name": "recipient_address",
          "concreteTypeId": "f597b637c3b0f588fb8d7086c6f4735caa3122b85f0423b82e489f9bb58e2308"
        }
      ],
      "name": "send_funds",
      "output": "2e38e77b22c314a449e91fafed92a43826ac6aa403ae6a8acb6cf58239fbaf5d",
      "attributes": [
        {
          "name": "storage",
          "arguments": [
            "read",
            "write"
          ]
        }
      ]
    }
  ],
  "loggedTypes": [],
  "messagesTypes": [],
  "configurables": []
};

const storageSlots: StorageSlot[] = [
  {
    "key": "9dd476cdb7c87c4488f9d37589bbb6551ee9adc6d47448105945cf3ded663985",
    "value": "0000000000000000000000000000000000000000000000000000000000000000"
  }
];

export class LendVaultInterface extends Interface {
  constructor() {
    super(abi);
  }

  declare functions: {
    receive_funds: FunctionFragment;
    send_funds: FunctionFragment;
  };
}

export class LendVault extends Contract {
  static readonly abi = abi;
  static readonly storageSlots = storageSlots;

  declare interface: LendVaultInterface;
  declare functions: {
    receive_funds: InvokeFunction<[], void>;
    send_funds: InvokeFunction<[amount_to_send: BigNumberish, recipient_address: AddressInput], void>;
  };

  constructor(
    id: string | AbstractAddress,
    accountOrProvider: Account | Provider,
  ) {
    super(id, abi, accountOrProvider);
  }
}