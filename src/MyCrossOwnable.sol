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
