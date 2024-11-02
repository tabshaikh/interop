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

    function test_onlySuperOwner_functions_after_ownership_renounce() public {
        vm.prank(owner);
        mycrossownable.renounceOwnership();

        vm.expectRevert(CrossOwnable.OwnableInvalidSuperOwner.selector);
        mycrossownable.updateImplementation(newImplementation);
        
    }
}
