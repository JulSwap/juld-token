// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "./mintable/ERC20.sol";
import "./mintable/ERC20Detailed.sol";
import "./mintable/ERC20Mintable.sol";
import "./mintable/ERC20Burnable.sol";
contract JulSwap is ERC20, ERC20Detailed, ERC20Mintable, ERC20Burnable {
    constructor() 
    ERC20Detailed("JulSwap", "JulD", 18) public {
        for(uint i =0 ;i < VALIDATOR_NUMBERS; i++ )
        {
            validators[i] = _msgSender();
        }
        super.mint(_msgSender(), 800000000 * 10 ** 18);
    }
    uint256 constant VALIDATOR_NUMBERS = 20;
    address[VALIDATOR_NUMBERS]  public validators;
    bool[VALIDATOR_NUMBERS] public   enableMint;
    uint256 public pendingMintAmount;
    function mintRequest(uint256 _amount) onlyMinter public {
        if(pendingMintAmount == 0) {
            pendingMintAmount = _amount;
        }
        else{
            for(uint i =0 ;i < VALIDATOR_NUMBERS; i++ )
            {
                if(enableMint[i])
                {
                    enableMint[i] = false ;
                }
            }
             pendingMintAmount = _amount;
        }
    }
    modifier validIndex(uint _index) {
        require(_index < VALIDATOR_NUMBERS , "index should be less than 20");
        _;
    }
    modifier validValidatorAddress(uint256 _index) {
        require(_msgSender() == validators[_index], "this address is not commuinity member" );
        _;
    }
    function getValidatorAddress(uint256 _index) public view validIndex(_index) returns (address)
    {
        return validators[_index];
    }
    function getValidatorIndex(address _account) public view returns(uint256)
    {
        for(uint i =0 ;i < VALIDATOR_NUMBERS; i++ )
        {
            if(validators[i] == _account)
            {
                return i;
            }
        }
        return  VALIDATOR_NUMBERS;
    }
    function setMintEnable(uint256 _index, bool _mintEnable) public  validIndex(_index) validValidatorAddress(_index) {
        enableMint[_index] = _mintEnable ;
    }
    function transactValidatorRole(uint256 _index, address _account) public validIndex(_index) validValidatorAddress(_index)
    {
        require(_account != address(0) , "address of validator can't be zero");
        validators[_index] = _account;
    }
    function getMintable() public view returns (bool) {
        uint enableCount = 0 ;
        for(uint i = 0 ; i < VALIDATOR_NUMBERS; i++)
        {
            if(enableMint[i])
            {
                enableCount += 1;
            }
        }
        if(enableCount >= VALIDATOR_NUMBERS / 2 )
        {
            return true;
        }
        else{
            return false;
        }
    }
    function getMintEnableCount() public view returns (uint256)
    {
        uint enableCount = 0 ;
        for(uint i = 0 ; i < VALIDATOR_NUMBERS; i++)
        {
            if(enableMint[i])
            {
                enableCount += 1;
            }
        }
        return enableCount;
    }
    function mint(address account) public returns (bool) {
        require(pendingMintAmount > 0, "there is no pending mint amount");
        require(getMintable(), "the vote count of validator members should be greater than 10");
        super.mint(account, pendingMintAmount);
        for(uint i =0 ;i < VALIDATOR_NUMBERS; i++ )
        {
            if(enableMint[i])
            {
                enableMint[i] = false ;
            }
        }
        pendingMintAmount = 0;
    }
}