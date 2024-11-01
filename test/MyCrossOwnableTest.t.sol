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
