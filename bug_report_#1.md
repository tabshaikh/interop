
## Summary
The OnlySuperOwner modifier does not check if the msg.sender is the rightful owner for calling this method . Which can be leveraged to call onlySuperOwner functions even if the ownership is renounced .

Actually , inside this abstract contract `CrossOwnable` , whenever we use `onlySuperOwner` , we use it `in conjunction with onlyOwner modifer`. However , this might not be always the case as its quite misleading .

OnlySuperOwner should not depend on some other modifer to check the partial state it is relying on . Instead it must ensure itself that msg.sender is the rightful current owner too instead of just checking the `boolean isSuperOwner` variable which is not reset when ownership is renounced.

The practical consideration is when devs just use `onlySuperOwner` modifier on critical functions and not `onlyOwner` preceeded by it as it is not mandatory for now ( due to no docs and inline comments stating that )

For example , say a function `updateImplementation` in the `crossOwnable` inherited contract which only enforces `onlySuperOwner`

```solidity
import "./CrossOwnable.sol";

contract MyCrossOwnable is CrossOwnable {
    address implementation;

    constructor(
        address initialOwner,
        address _previousContract,
        bool _isSuperOwner
    ) CrossOwnable(initialOwner, previousContract, isSuperOwner) {}

    function updateImplementation(address newImplementation) public onlySuperOwner {
        implementation = newImplementation;
    }
}

```
In this way , even after ownership is renounced , the method will still be able to operate.

## PoC

```solidity
import "forge-std/Test.sol";
import "../src/MyCrossOwnable.sol";

contract CrossOwnableTest is Test {
    MyCrossOwnable mycrossownable;
    address owner = makeAddr("owner");
    address previousContract = makeAddr("previousContract");
    address newImplementation = makeAddr("newImplementation");

    function setUp() public {
        mycrossownable = new MyCrossOwnable(owner, previousContract, true);
    }

    function test_isSuperOwner_active_after_renounceOwnership() public {
        vm.prank(owner);
        mycrossownable.renounceOwnership();
        mycrossownable.updateImplementation(newImplementation);
        
    }
}

```


