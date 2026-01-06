//SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import {LNS} from "src/registry/interfaces/LNS.sol";
import {IReverseRegistrar} from "src/registrar/interfaces/IReverseRegistrar.sol";
import {ADDR_REVERSE_NODE} from "src/utils/Constants.sol";

contract ReverseClaimer {
    constructor(LNS lns, address claimant) {
        IReverseRegistrar reverseRegistrar = IReverseRegistrar(lns.owner(ADDR_REVERSE_NODE));
        reverseRegistrar.claim(claimant);
    }
}
