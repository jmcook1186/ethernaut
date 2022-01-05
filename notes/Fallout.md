## Exercise 2: Fallout

This contract is exploitable because the function that was intended to be the constructor is both spelled incorrectly and missing the "constructor" keyword. This means what was intended to be the constructor (i.e. executed a single time, on deployment) is a normal, publicly acessible function. Inside this function, the contract ownership is transferred to msg.sender. Therefore, to take ownership of the contract, we just need to execute this function.

The vulnerability:

```javascript
  
  /* constructor */
  function Fal1out() public payable {
    owner = msg.sender;
    allocations[owner] = msg.value;
  }

  ```

The exploit:

```javascript
contract.Fal1out()

```