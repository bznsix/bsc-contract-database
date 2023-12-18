//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface Token {
    function transfer(address to, uint tokens) external returns (bool success);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) ;
      function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);

    }
contract DuStake
    {
       
        address  public owner=0x949535BB1192e5509fff513A72eC4381228ff59b;              


        address Staking_token = 0xe298eD3543B45037A2D4037ac6dfeB2E801f9803; //DU


        uint public totalusers;
        uint private key;

        uint public per_day_divider= 1 days;
        
        uint public bonus= 8*10**18;
        uint public minimum_investment=10*10**18;
        uint public minimum_withdraw_reward_limit=1*10**18;
        uint public maximum_withdraw_reward_limit=2500*10**18;

        uint public penaltybefore30days= 8*10**18;
        uint public withdrawfee= 5*10**18;

        mapping(address=>uint) public trasactionCount;

        mapping(address=>uint) public Total_TeamStakeOf;

        uint64[12] public levelpercentage = [0.4 ether,0.33 ether,0.1666 ether,0.1 ether,0.0667 ether,0.033 ether,0.033 ether,0.033 ether,0.033 ether,0.033 ether,0.0667 ether,0.1 ether];
        uint[12] public level_tokens= [5000 *10**18,10000 *10**18,15000 *10**18,20000 *10**18,25000 *10**18,30000 *10**18,35000 *10**18,40000 *10**18,45000 *10**18,50000 *10**18,55000 *10**18,60000 *10**18];

        uint public totalbusiness; 
        uint public totalwithdraw; 


        struct allInvestments{

            uint investedAmount;
            uint withdrawnTime;
            uint DepositTime;
            uint investmentNum;
            uint unstakeTime;
            bool unstake;
            uint apr;
            uint timeframe;


        }



        struct Data{

            mapping(uint=>allInvestments) investment;
            uint noOfInvestment;
            uint totalInvestment;
            uint totalWithdraw_reward;
            bool investBefore;
            address[] myReferrals;
            address referralFrom;  
            mapping(uint=>level_data) level;
            uint totalDirects;
            uint totalTeam;
        }


        struct time_Apy
        {
            uint timeframe;
            uint APR;
        }

        struct level_data
        {
            bool eligible;
            uint eligible_time;
            uint count; 


        }

        struct history
        {
            uint events;
            uint amount;
            uint time;


        }

        mapping(address=>Data) public user;
        mapping(uint=>time_Apy) public details;
        mapping(address=>mapping(uint=>history)) public historyOf;
        mapping(address=>uint) public BonusOf;


        mapping(address=>mapping(uint=>allInvestments)) public user_investments;

        modifier onlyOwner() {
        require(msg.sender == owner);
        _; 
    }
        constructor(uint _key){
            

            key=_key;


            details[0].timeframe=200 days;
            details[1].timeframe=400 days;


            details[0].APR=100;
            details[1].APR=240;




        }
        
        function sendRewardToReferrals(address investor,uint _investedAmount)  internal  //this is the freferral function to transfer the reawards to referrals
        { 
 
            address temp = investor;
            uint i=0;

                do
                {

                    Total_TeamStakeOf[temp]+=_investedAmount;


                    if(user[investor].noOfInvestment==1)
                    {
                        user[temp].totalTeam++;

                        if(user[temp].referralFrom!=address(0))
                        {
                            user[user[temp].referralFrom].level[i].count++;

                        }
                    }

                    for(uint j=0;j<12;j++)
                    {
                        if((Total_TeamStakeOf[temp]>=level_tokens[j]) && !user[temp].level[j].eligible)
                        {
                            user[temp].level[j].eligible=true;
                            user[temp].level[j].eligible_time=block.timestamp;

                            uint count=trasactionCount[temp];
                            historyOf[temp][count].events=4;
                            historyOf[temp][count].amount=level_tokens[j];
                            historyOf[temp][count].time=block.timestamp;
                            trasactionCount[temp]++;

                        }
                    }
                    temp=user[temp].referralFrom;

                    i++;
                    
                } 
                while(temp!=address(0));

        }
       


        function Stake(uint _investedamount,uint choose_val,uint _key,address _ref) external returns(bool success)
        {

            require(key==_key);
            require(_investedamount >= minimum_investment  );     //ensuring that investment amount is not less than zero

            require(details[choose_val].APR > 0);
            require(_investedamount > 0);     
            require(Token(Staking_token).allowance(msg.sender,address(this))>=_investedamount);

            if(user[msg.sender].investBefore == false && msg.sender!=owner)
            { 


                if(_ref==address(0) || _ref==msg.sender || _ref==owner)
                {
                    
                    user[msg.sender].referralFrom=owner;
                    _ref=owner;
                    user[_ref].myReferrals.push(msg.sender);
                    uint bon = (bonus * _investedamount)/(100*10**18);
                    BonusOf[_ref]+=bon;
                }
                else 
                {
                    user[msg.sender].referralFrom=_ref;
                    user[_ref].myReferrals.push(msg.sender);
                    uint bon = (bonus * _investedamount)/(100*10**18);
                    BonusOf[_ref]+=bon;

                }
                
                user[_ref].totalDirects++;

                totalusers++;                                     
            }

            
            uint num = user[msg.sender].noOfInvestment;
            user[msg.sender].investment[num].investedAmount =_investedamount;
            user[msg.sender].investment[num].DepositTime=block.timestamp;
            user[msg.sender].investment[num].withdrawnTime=block.timestamp + details[choose_val].timeframe ;  
            
            user[msg.sender].investment[num].investmentNum=num;
            user[msg.sender].investment[num].apr=details[choose_val].APR;
            user[msg.sender].investment[num].timeframe=(details[choose_val].timeframe/per_day_divider);  

            user[msg.sender].totalInvestment+=_investedamount;
            user[msg.sender].noOfInvestment++;
            totalbusiness+=_investedamount;

            Token(Staking_token).transferFrom(msg.sender,address(this),_investedamount);
            user_investments[msg.sender][num] = user[msg.sender].investment[num];
            user[msg.sender].investBefore=true;

            uint temp=trasactionCount[msg.sender];
            historyOf[msg.sender][temp].events=1;
            historyOf[msg.sender][temp].amount=_investedamount;
            historyOf[msg.sender][temp].time=block.timestamp;
            trasactionCount[msg.sender]++;
            sendRewardToReferrals( msg.sender, _investedamount);

            return true;
            
        }

       function get_TotalReward() view public returns(uint)
       { 
            uint totalReward;
            uint depTime;
            uint rew;
            uint temp = user[msg.sender].noOfInvestment;
            for( uint i = 0;i < temp;i++)
            {   
                if(!user[msg.sender].investment[i].unstake)
                {
                    if(block.timestamp < user[msg.sender].investment[i].withdrawnTime)
                    {
                        depTime =block.timestamp - user[msg.sender].investment[i].DepositTime;
                    }
                    else
                    {    
                        depTime =user[msg.sender].investment[i].withdrawnTime - user[msg.sender].investment[i].DepositTime;
                    }                
                }
                else{
                    depTime =user[msg.sender].investment[i].unstakeTime - user[msg.sender].investment[i].DepositTime;
                }
                depTime=depTime/per_day_divider; //1 day
                if(depTime>0)
                {
                     rew  =  (((user[msg.sender].investment[i].investedAmount * ((user[msg.sender].investment[i].apr) *10**18) )/ (100*10**18) )/(user[msg.sender].investment[i].timeframe));


                    totalReward += depTime * rew;
                }
            }
            return totalReward;
        }



        function getReward_perInv(uint i,uint point) view public returns(uint){ 
            uint totalReward;
            uint depTime;
            uint rew;
            uint apr;

                if(!user[msg.sender].investment[i].unstake)
                {
                    if(block.timestamp < user[msg.sender].investment[i].withdrawnTime)
                    {
                        depTime =block.timestamp - user[msg.sender].investment[i].DepositTime;
                    }
                    else
                    {    
                        depTime =user[msg.sender].investment[i].withdrawnTime - user[msg.sender].investment[i].DepositTime;
                    }                
                }
                else{
                    depTime =user[msg.sender].investment[i].unstakeTime - user[msg.sender].investment[i].DepositTime;
                }
                depTime=depTime/per_day_divider; //1 day
                if(depTime>0)
                {
                    if(point==1)
                    {
                        if(user[msg.sender].investment[i].apr==100)
                        {
                            apr=66.6 ether;
                        }
                        else{
                            apr=173.2 ether;

                        }
                    }
                    else{
                        if(user[msg.sender].investment[i].apr==100)
                        {
                            apr=100 ether;
                        }
                        else{
                            apr=200 ether;

                        }
                    }

                     rew  =  (((user[msg.sender].investment[i].investedAmount * apr  )/ (100*10**18) )/(user[msg.sender].investment[i].timeframe));


                    totalReward += depTime * rew;
                }
            

            return totalReward;
        }


        function getLevelReward_perInv(uint i,address inv,uint _level,address main) view public returns(uint){ //this function is get the total reward balance of the investor
            uint totalReward;
            uint depTime;
            uint rew;

                if(!user[inv].investment[i].unstake)
                {
                    
                    if(block.timestamp < user[inv].investment[i].withdrawnTime)
                    {
                        depTime =block.timestamp - user[main].level[_level].eligible_time;
                    }
                    else
                    {    
                        depTime =user[inv].investment[i].withdrawnTime - user[main].level[_level].eligible_time;
                    }                        
                
                }
                else
                {
                    depTime =user[inv].investment[i].unstakeTime - user[main].level[_level].eligible_time;
                }
                depTime=depTime/per_day_divider; //1 day
                if(depTime>0)
                {
                     rew  =  (((user[inv].investment[i].investedAmount * ((user[inv].investment[i].apr) *10**18) )/ (100*10**18) )/(user[inv].investment[i].timeframe));


                    totalReward += depTime * rew;
                }
            

            return totalReward;
        }


        function unStake(uint num) external  returns (bool success)
        {
            require(user[msg.sender].investment[num].investedAmount>0);            
            require(!user[msg.sender].investment[num].unstake);
            uint amount=user[msg.sender].investment[num].investedAmount;
            totalbusiness-=amount;
            if(user[msg.sender].investment[num].DepositTime + 30 days > block.timestamp)
            {
                uint penalty_fee=(amount*penaltybefore30days)/(100 ether) ;
                Token(Staking_token).transfer(owner,penalty_fee);            
                amount=amount-penalty_fee;
            }
            else if(user[msg.sender].investment[num].withdrawnTime > block.timestamp)
            {
                uint penalty_fee=getReward_perInv(num,2) - getReward_perInv(num,1);
                Token(Staking_token).transfer(owner,penalty_fee);            
                amount=amount-penalty_fee;
            }
            Token(Staking_token).transfer(msg.sender,amount);            
          
            user[msg.sender].investment[num].unstake =true;    
            user[msg.sender].investment[num].unstakeTime =block.timestamp;    

            user[msg.sender].totalInvestment-=user[msg.sender].investment[num].investedAmount;
            user_investments[msg.sender][num] = user[msg.sender].investment[num];

            uint temp=trasactionCount[msg.sender];
            historyOf[msg.sender][temp].events=2;
            historyOf[msg.sender][temp].amount=amount;
            historyOf[msg.sender][temp].time=block.timestamp;
            trasactionCount[msg.sender]++;

            return true;

        }



        function getTotalInvestment() public view returns(uint) {   //this function is to get the total investment of the ivestor
            
            return user[msg.sender].totalInvestment;

        }
        
        function get_totalEarning() public view returns(uint) {   //this function is to get the total investment of the ivestor
            
            uint[] memory arr= new uint[](12);
            arr=Level_earning(msg.sender);
            uint total_levelReward;
            for(uint i=0;i<12;i++)
            {
                total_levelReward+=arr[i];
            }
            return (( get_TotalReward() + BonusOf[msg.sender] + total_levelReward) - user[msg.sender].totalWithdraw_reward );

        }

        function withdrawReward(uint _vlaue) external returns (bool success){
            uint Total_reward = get_totalEarning();
            
            require(_vlaue >= minimum_withdraw_reward_limit && _vlaue <= maximum_withdraw_reward_limit ,"limit issue");     //ensuring that investment amount is not less than zero

            require(Total_reward>=_vlaue);         //ensuring that if the investor have rewards to withdraw
            totalwithdraw+=_vlaue;
            user[msg.sender].totalWithdraw_reward+=_vlaue;

            uint withdraw_fee=(_vlaue*(withdrawfee))/(100*10**18);
            Token(Staking_token).transfer(owner,withdraw_fee);            
            _vlaue=_vlaue-withdraw_fee;

            Token(Staking_token).transfer(msg.sender,_vlaue);             // transfering the reward to investor             
            uint temp=trasactionCount[msg.sender];

            historyOf[msg.sender][temp].events=3;
            historyOf[msg.sender][temp].amount=_vlaue;
            historyOf[msg.sender][temp].time=block.timestamp;
            trasactionCount[msg.sender]++;

            return true;

        }

        function getAll_investments() public view returns (allInvestments[] memory Invested)
        { 
            uint num = user[msg.sender].noOfInvestment;
            uint temp;
            uint currentIndex;
            
            for(uint i=0;i<num;i++)
            {
               if(!user[msg.sender].investment[i].unstake )
               {
                   temp++;
               }

            }
         
           allInvestments[] memory temp_arr =  new allInvestments[](temp) ;
            Invested =  new allInvestments[](temp) ;

            for(uint i=0;i<num;i++)
            {
               if( !user[msg.sender].investment[i].unstake ){

                   temp_arr[currentIndex]=user[msg.sender].investment[i];

                   currentIndex++;
               }

            }

            uint count=temp;
            for(uint i=0;i<temp;i++)
            {
                count--;
                Invested[i]=temp_arr[count];

            }

            return Invested;

        }
        
        function get_upliner(address inv) public view returns(address)
        {
            return user[inv].referralFrom;
        }


        function Level_earning(address inv) public view returns( uint[] memory arr1 )
        { 

            uint[] memory levelRewards = new uint[](12);

            uint calc_rew; 
            address[] memory direct_members = user[inv].myReferrals;
            uint next_member_count;

            for(uint j=0; j < 12;j++) //levels
            {

                if(user[inv].level[j].eligible)
                {
                    for( uint k = 0;k < direct_members.length;k++) //members
                    {   
                        
                        next_member_count+=user[direct_members[k]].myReferrals.length;

                        uint temp = user[direct_members[k]].noOfInvestment; 

                        for( uint i = 0;i < temp;i++) //investments
                        {   
                            // if(user[direct_members[k]].investment[i].DepositTime<=user[inv].level[j].eligible_time)
                            // {
                            uint temp_amount = getLevelReward_perInv(i,direct_members[k],j,inv);
                            calc_rew +=  ((temp_amount * (levelpercentage[j]) )/ (100*10**18) );

                            // }
                            
                        }


                                    
                    }
                    levelRewards[j]=calc_rew;
                    calc_rew=0;

                    address[] memory next_members=new address[](next_member_count) ;

                    for( uint m = 0;m < direct_members.length;m++) //members
                    {   
                        for( uint n = 0; n < user[direct_members[m]].myReferrals.length; n++) //members
                        {   
                            next_members[calc_rew]= user[direct_members[m]].myReferrals[n];
                            calc_rew++;
                        }
                    }
                    direct_members=next_members; 
                    next_member_count=0;
                    calc_rew=0;


                }
                
            }
                

            
            

            return levelRewards;
        }



        function Level_count(address inv) public view returns( uint[] memory _arr )
        {
            uint[] memory referralLevels_count=new uint[](12);

            for(uint i=0;i<12;i++)
            {
                referralLevels_count[i] = user[inv].level[i].count;
            }
            return referralLevels_count ;


        }
        
        function get_history(address inv) public view returns( history[] memory _arr )
        {
            uint temp=trasactionCount[msg.sender];

            _arr=new history[](temp);
            for(uint i=0;i<temp;i++)
            {

                    _arr[i] = historyOf[inv][i];



            }
            return _arr ;


        }

  
        function transferOwnership(address _owner)  public
        {
            require(msg.sender==owner);
            owner = _owner;
        }

        function total_withdraw_reaward() view public returns(uint){


            return user[msg.sender].totalWithdraw_reward;

            

        }
        



       function withdrawFunds(uint _amount)  public
        {
            require(msg.sender==owner);

            uint bal = Token(Staking_token).balanceOf(address(this));
            _amount*=10**18;
            require(bal>=_amount);

            Token(Staking_token).transfer(owner,_amount); 
        }

        //updtae values

        function update_minimum_withdraw_reward_limit(uint inv) onlyOwner public
        {

            minimum_withdraw_reward_limit=inv;
        }

        function update_minimum_investment(uint inv) onlyOwner public
        {

            minimum_investment=inv;
        }        
        
        function update_maximum_withdraw_reward_limit(uint inv) onlyOwner public
        {

            maximum_withdraw_reward_limit=inv;
        }
        
        function update_Unstake_penaltybefore30days(uint inv) onlyOwner public
        {

            penaltybefore30days=inv;
        }        
        function update_key(uint _key) onlyOwner public
        {
            key=_key;
        }        
        
        function update_withdrawfee(uint inv) onlyOwner public
        {
            withdrawfee=inv;
        } 
    }