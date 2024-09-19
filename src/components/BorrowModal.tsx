"use client";

import { useState, FC, useEffect } from "react";
import {
  Dialog,
  DialogBackdrop,
  DialogPanel,
  DialogTitle,
} from "@headlessui/react";
import { CheckIcon } from "@heroicons/react/24/outline";

type ModalType = {
  canProceed: boolean;
  setCanProceed: React.Dispatch<React.SetStateAction<boolean>>;
  handleSubmit: () => void;
  loadAmount: number;
  collateralAmount: number;
  interest: string;
  repaymentDate: string;
};

export const BorrowModal: FC<ModalType> = ({
  canProceed,
  setCanProceed,
  handleSubmit,
  loadAmount,
  collateralAmount,
  interest,
  repaymentDate
}) => {
  return (
    <Dialog
      open={canProceed}
      onClose={() => setCanProceed(false)}
      className="relative z-10"
    >
      <DialogBackdrop
        transition
        className="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity"
      />

      <div className="fixed inset-0 z-10 w-screen overflow-y-auto">
        <div className="flex min-h-full items-end justify-center p-4 text-center sm:items-center sm:p-0">
          <DialogPanel
            transition
            className="relative transform overflow-hidden rounded-lg bg-white px-4 pb-4 pt-5 text-left shadow-xl transition-all sm:my-8 sm:w-full sm:max-w-lg sm:p-6"
          >
            <div>
              <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-green-100">
                <CheckIcon
                  aria-hidden="true"
                  className="h-6 w-6 text-green-600"
                />
              </div>
              <div className="mt-3 text-center sm:mt-5">
                <DialogTitle
                  as="h3"
                  className="text-base font-semibold leading-6 text-gray-900"
                >
                  Do you want to proceed?
                </DialogTitle>
                <div className="mt-2">
                  <div className="rounded-lg bg-gray-50 px-4 py-6">
                    <dl className="divide-y divide-gray-200 text-sm">
                      <div className="flex items-center justify-between pb-4">
                        <dt className="text-gray-600">Loan Amount</dt>
                        <dd className="font-medium text-gray-900">{loadAmount}</dd>
                      </div>
                      <div className="flex items-center justify-between py-4">
                        <dt className="text-gray-600">
                          Assets to Deposit (Ether)
                        </dt>
                        <dd className="font-bold text-bg-cyan-800">
                          {collateralAmount}
                        </dd>
                      </div>
                      <div className="flex items-center justify-between py-4">
                        <dt className="text-gray-600">Interest</dt>
                        <dd className="font-medium text-gray-900">{interest}</dd>
                      </div>
                      <div className="flex items-center justify-between py-4">
                        <dt className="font-medium text-gray-900">
                          Repayment Date
                        </dt>
                        <dd className="font-medium text-indigo-600">
                          {repaymentDate}
                        </dd>
                      </div>
                    </dl>
                  </div>
                </div>
              </div>
            </div>
            <div className="mt-5 sm:mt-6 sm:grid sm:grid-flow-row-dense sm:grid-cols-2 sm:gap-3">
              <button
                type="button"
                onClick={() => setCanProceed(false)}
                className="flex w-full justify-center rounded-md bg-white text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 border border-cyan-700"
              >
                Cancel
              </button>
              <button
                type="button"
                onClick={handleSubmit}
                className="flex w-full justify-center items-center rounded-md bg-cyan-800 text-sm font-semibold text-white shadow-sm hover:bg-cyan-700"
              >
                Borrow
              </button>
            </div>
          </DialogPanel>
        </div>
      </div>
    </Dialog>
  );
};
