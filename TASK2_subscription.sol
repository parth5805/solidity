// SPDX-License-Identifier: GPL-3.0

pragma solidity >= 0.5.0 <0.9.0;

contract Subscription_Platform{
        address owner;

        struct Subscription{
                uint id;
                string name;
                uint price_per_period;
                mapping(address=>bool) subscribers_list;

        }
        mapping(uint=>Subscription) public subscriptions;
        uint subscriptions_count;

        struct Subscriber{
                address id;
                uint subscription_id;
                uint total_amount;
                uint subscription_date;
                uint total_period;

        }

        mapping(address=>Subscriber) public subscribers;


        constructor(){
        owner=msg.sender;
        }

        modifier onlyowner()
        {
        require(msg.sender==owner,"only owner can call this function");
        _;          
        }

        function addSubscription(string memory _name,uint _price_per_period) public onlyowner
        {
            subscriptions_count++;
            Subscription storage newSubscription=subscriptions[subscriptions_count];
            newSubscription.id=subscriptions_count;
            newSubscription.name=_name;
            newSubscription.price_per_period=_price_per_period;   
        }

        function Subscribe(uint _subscription_id) payable public 
        {
        require(msg.value>=1 ether,"minimum amount is greater then 1 ether");
        uint _total_amount=msg.value/1 ether;
        Subscription storage thisSubscription=subscriptions[_subscription_id];
        require(thisSubscription.subscribers_list[msg.sender]==false,"you have already subscribed this plan");
        require(_total_amount%thisSubscription.price_per_period==0,"total amount = (Subscription_price * any positive integer) ");
        thisSubscription.subscribers_list[msg.sender]=true;
        Subscriber storage newSubscriber=subscribers[msg.sender];
        newSubscriber.id=msg.sender;
        newSubscriber.subscription_id=_subscription_id;
        newSubscriber.total_amount=_total_amount;
        newSubscriber.subscription_date=block.timestamp;
        newSubscriber.total_period=_total_amount/thisSubscription.price_per_period;
        }

        function check_subscription(uint _subscription_id) public view returns(uint)
        {
        Subscription storage thisSubscription=subscriptions[_subscription_id];
        require(thisSubscription.subscribers_list[msg.sender]==true,"you have not subscribed this plan");  
        Subscriber storage thisSubscriber=subscribers[msg.sender]; 
        uint total_term=thisSubscriber.total_period;
        uint current_term=(block.timestamp-thisSubscriber.subscription_date)/10; //every 10 seconds is 1 term
        uint time_left=total_term-current_term;
        require(time_left>0,"your subscription plan is over");
        return time_left;
        }

        function get_C_balance() public view returns(uint)
        {
                return address(this).balance;
        }
}