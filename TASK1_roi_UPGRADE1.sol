// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 <0.9.0;

contract ROI_Platform{
        uint public minimumAmount;
        address public manager;
        uint public now_time=block.timestamp;

        struct Investor{
            address payable account_no;
            uint invested_amount;
            uint invested_date;
            uint gained_amount;
        }

        mapping(address=>Investor) public investors;

        constructor(){
        manager=msg.sender;
        minimumAmount=0.01 ether;
        }

    function invest() public payable
    {
        require(msg.value >=minimumAmount,"minimum amount atleast 0.01 ether");   
        require(getTerm()<=30,"maximum terms are 30 for ROI plan");
        uint invested_date;
        uint invested_amount;
        if(investors[msg.sender].invested_date>0)
        {   
        invested_date=investors[msg.sender].invested_date;
        invested_amount=investors[msg.sender].invested_amount + msg.value;

        }
        else
        {
        invested_date=block.timestamp;
        invested_amount=msg.value;
        }
        investors[msg.sender]=Investor(payable(msg.sender),invested_amount,invested_date,0);
    }

    modifier onlyManager(){
        require(msg.sender==manager,"only manager can call this function");
        _;
    }

    function get_Contract_Balance() view public onlyManager returns(uint) 
    {   
        return address(this).balance;
    }
    
    function getTerm() public view returns(uint)
    {
        uint term;
        if(investors[msg.sender].invested_date>0)
        {
        Investor storage thisinvestor=investors[msg.sender];
        uint current_date=block.timestamp;
        uint total_time_differnce=current_date-thisinvestor.invested_date;
        term=total_time_differnce/15; //15=every 15 second is 1 term, on every term investor will get 3% return
        }
        return term;
    }

    function check_investment() public view returns(uint)
    {
        require(investors[msg.sender].invested_amount>0,"you account balance is zero");
        Investor storage thisinvestor=investors[msg.sender];
        uint current_balance=thisinvestor.invested_amount;
        uint term=getTerm();
        if(term<=30)
        {    
            current_balance=current_balance + thisinvestor.invested_amount*3/100*term;
        }
        else
        {
            term=30;
            current_balance=current_balance + thisinvestor.invested_amount*3/100*term;
        }
        return current_balance;
    }

    function withdraw_investment(uint amount) public
    {
        Investor storage thisinvestor=investors[msg.sender];
        investors[msg.sender].gained_amount=check_investment();
        uint withdraw_balance=amount;
        require(investors[msg.sender].gained_amount >= withdraw_balance,"insufficient account balance");
        payable(thisinvestor.account_no).transfer(withdraw_balance);
        thisinvestor.invested_amount=investors[msg.sender].gained_amount-withdraw_balance;
        investors[msg.sender].gained_amount=0;
    }

    function sendfunds_to_contract() public onlyManager payable
    {
        //by using this function manager can add earned money and send it to the contract balance.
    } 
}
