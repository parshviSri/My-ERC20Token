// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v3.0.0/contracts/token/ERC20/IERC20.sol";
interface IERC20 {
    function transfer(address recipient, uint amount) external  returns (bool);
    function approve(address spender, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract  MyToken  is  IERC20 {
    // variables required
    uint totalSupply;
    mapping(address => uint) balanceOf;
    mapping(address => mapping(address => uint)) allowance;
    string name = "Curious owl";
    string symbol = "CO";
    uint decimal = 18;

    function transfer(address recipient, uint amount) external override(IERC20) returns (bool){
        balanceOf[msg.sender] -= amount;
        balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient,amount);
        return true;
    }


    function approve(address spender, uint amount) external override(IERC20) returns (bool){
       allowance[msg.sender][spender]=amount;
       emit Approval(msg.sender,spender,amount);
       return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external  override(IERC20) returns (bool){
        allowance[sender][msg.sender] -= amount;
        balanceOf[sender] -= amount;
        balanceOf[recipient] +=amount;
        emit Transfer(sender, recipient,amount);
        return true;
    }
    function mint (uint amount) external {
        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
    }

    function burnt (uint amount) external {
        totalSupply -= amount;
        balanceOf[msg.sender] -= amount;
        emit Transfer(msg.sender,address(0), amount);

    }

}
// token Swap
// You have token 1 of amount 1 and you want to swap token 2 of amount 2 
contract TokenSwap{
    IERC20 public token1;
    uint public amount1;
    address public owner1;
    IERC20 public token2;
    uint public amount2;
    address public owner2;
    constructor(
        address _token1,
        address _owner1,
        uint _amount1,
        address _token2,
        address _owner2,
        uint _amount2

    ){
    token1 = IERC20(_token1);
    owner1 = _owner1;
    amount1 = _amount1;
    token2 = IERC20(_token2);
    owner2 = _owner2;
    amount2 = _amount2;
    }

    function swap() external {
        require (msg.sender == owner1 || msg.sender == owner2," You don't have the authority !!");
        require (token1.allowance(owner1, address(this))>= amount1," Token is less than amount");
        require (token2.allowance(owner1, address(this))>= amount2," Token is less than amount");
        _safeTransfer(token1,owner1,owner2,amount1);
        _safeTransfer(token2,owner2,owner1,amount2);


    }
    function _safeTransfer  (IERC20  _token,address _sender, address _recipient, uint _amount) private{
         bool success = _token.transferFrom(_sender,_recipient,_amount);
         require(success, "Swapping failed !!");
    }
   
}
