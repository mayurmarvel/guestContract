// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.0;

contract Guest{

    uint256 public totalMessages;

    uint256 public totalGuests;

    uint256 public deletedMessages;

    mapping(address => string) public users;

    mapping(address => uint256) public lastMessageTime;

     struct Message {
        uint256 id;
        string username;
        address sender;
        uint256 createdTime;
        string message;
        bool isDeleted;
        bool isSpam;
    }

    Message[] private messages;

    address admin;

    constructor() {
        admin = msg.sender;
        users[admin] = "admin";
    }

    // A modifier to allow only the registered users.
     modifier onlyRegisteredUser() {
        require(keccak256(abi.encodePacked(users[msg.sender])) != keccak256(abi.encodePacked("")), "Not a Registered User!");

        _;
    }

    // A modifier to allow only Admin
     modifier onlyAdmin() {
        require(keccak256(abi.encodePacked(msg.sender)) == keccak256(abi.encodePacked(admin)), "You are not Admin!");

        _;
    }


    // For Registering a User and also to update the Username
    function registerUser(string memory _username) public {
        users[msg.sender] = _username;
        totalGuests += 1;
    }

    
    // Making the Post
    function postMessage(string memory _message) public onlyRegisteredUser{
        // checking for Empty Messages
        require(keccak256(abi.encodePacked(_message)) != keccak256(abi.encodePacked("")), "Message should not be Empty");

        // checking whether the lastMessage Posted by the Guest is above HALF Hour
// To-do Update Half an Hour Time Seconds - 1800
        require((block.timestamp - lastMessageTime[msg.sender]) >= 30 ," You should wait Half an Hour before posting your Next Message");

        // Adding Messages to the Messages Array 
        messages.push(Message(totalMessages, users[msg.sender] , msg.sender, block.timestamp, _message, false, false));

        lastMessageTime[msg.sender] = block.timestamp;

        totalMessages += 1;
    }



    function getAMessage(uint _id) public view returns(Message memory){
        return messages[_id];
    }


    function getAllMessages() public view returns(Message[] memory){

        Message[] memory allMessages = new Message[] (totalMessages); 

        for (uint i = 0; i < totalMessages; i++) {

            Message storage message = messages[i];
            allMessages[i] = message;
            allMessages[i].username = users[allMessages[i].sender];

        }
        return allMessages;
    }


    // get Messages of Specific User with Address
    function getMessages(address _userAddress) public view returns (Message[] memory ){

        Message[] memory userMessages = new Message[] (totalMessages); 

        uint32 individualMsgCount = 0;

        for (uint i = 0; i < totalMessages; i++) {

            if(messages[i].sender == _userAddress){
                Message storage message = messages[i];
                userMessages[individualMsgCount] = message;
                individualMsgCount += 1;
            }
            
        }

        return userMessages;

    }


    // The Message Creator can able to Edit the Message
    function editMessage(uint256 _id, string memory _newMessage) public returns (bool){
        require(keccak256(abi.encodePacked(messages[_id].sender)) == keccak256(abi.encodePacked(msg.sender)) && messages[_id].isSpam == false  && messages[_id].isDeleted == false, "You are not the Message Creator or This Message is Flagged as a Spam or Deleted");
//To-DO Update to 5 mins - 300 Seconds
        require((block.timestamp - messages[_id].createdTime) <= 120  , "Message cannot be edited after 5 Mins of Creation");
        messages[_id].message = _newMessage;
        return true;

    }


    // The Message Creator and Admin can able to Delete the Message
    function deleteMessage(uint256 _id) public returns (bool){

        //Check whether the message is already deleted
        require(messages[_id].isDeleted == false, "Message already Deleted");
        require(keccak256(abi.encodePacked(messages[_id].sender)) == keccak256(abi.encodePacked(msg.sender)) || keccak256(abi.encodePacked(admin)) == keccak256(abi.encodePacked(msg.sender)), "You are not the Message Creator");

        messages[_id].message = "";
        messages[_id].isDeleted = true;
        deletedMessages += 1;
        return true;

    }

    // The Admin can able to mark a Message as Spam
    function flagSpam(uint256 _id) public onlyAdmin returns (bool){
        return messages[_id].isSpam = true;

    }

    // Admin account can be updated by admin
    function changeAdmin(address _newAdmin) public onlyAdmin returns (bool){
        admin = _newAdmin;
        return true;
    }



}
