## Exercise 8: Vault

The aim of the vault exercise is to unlocm the vault by providing the secret password. The vulnerability is that the secret password is set in the contract's constructor and then kept in storage (i.e. publicly accessible on the blockchain). The "private" modifier only protects the variable from being accessed by other contracts, it does not keep the variable private from individuals retrieving data from the blockchain. Therefore, if we know the contract's deployment address, we can use knowledge of how data is stored on Ethereum, we can retrueve the secret password from the blockchain and pass it to the cojmntract in order to unlock the vault.

### Storage

Storage on Ethereum is 2<sup>256</sup> slots of 32 bytes each. Each individual contract deployed to the blockchain has its own storage associated with it. This is where values for its storage variables are persisted and it is tied to the contract's deployment address. The order in which variables are declared in a contract determines the order in which the data is added to storage, with space optimization achieved by allopwing multiple variables whose total size is < 32 bytes to share slots. So, if we have 4 variables: A = 3 bytes, B = 4 bytes, C = 7 bytes, and D = 25 bytes, A,B and C will all be stored in Slot 1, and D will be stored in Slot 2.

```

        SLOT 1                            SLOT 2
-------------------------------||---------------------------
A   B   C  0 0 0 0 0 0 0...    || D   0 0 0 0 0 0 0 0 0 ....

```

In the `Vault.sol` contract, the password is the second variable to be declared, after a bool. Since we know that the password is of type Bytes32, it must be int he second slot (since there is no space for it to fit in Slot 1 after a bool). Therefore, the password fills memory slot 2.

### Execution

Steps are to 1) get the password from storage; 2) pass the password as an argumenbt to `Vault.sol`'s `unlock()` function.

Start a brownie console session on Rinkeby, then:

```bash

>>> hacker = accounts.load('main')
>>> contract = Vault.at('0x62e6BF0ac588f35ADd13525F80CBe3f30d2Fa555')
# view initial lock status
>>> contract.locked()
    >>> true
# Vault.sol deployment address and 1 (second slot, indexing from zero)
>>> pw = web3.getStorageAt(contract.address,1)
    >>> HexBytes('0x412076657279207374726f6e67207365637265742070617373776f7264203a29')
>>> contract.unlock(pw, {'from': hacker})
# view new lock status
>>> contract.locked()
    >>> false
```

