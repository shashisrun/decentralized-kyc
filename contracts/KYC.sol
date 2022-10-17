//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.14;

contract KYC{

    address admin;

    uint256 bankCount = 0;
    uint256 customerCount = 0;

    constructor() {
      admin = msg.sender;
   }

    struct Customer {
        string userName;   
        string data;  
        address bank;
        bool kycStatus;
        uint256 downvotes;
        uint256 upvotes;
    }
    
    struct Bank {
        string name;
        address ethAddress;
        uint256 complaintsReported;
        uint256 kycCount;
        bool isAllowedToVote;
        string regNumber;
    }

    struct KYCRequest {
        string userName;   
        string data;  
        address bank;
    }

    mapping(string => Customer) customers;
    mapping(string => KYCRequest) requests;

    mapping(address => Bank) banks;

    // Bank Interface
    
    function addRequest(string memory _userName, string memory _customerData) public {
        require(banks[msg.sender].ethAddress != address(0), "Your are not authorized to add a request");
        require(requests[_userName].bank == address(0), "Request is already present");
        requests[_userName].userName = _userName;
        requests[_userName].data = _customerData;
        requests[_userName].bank = msg.sender;
    }

    function addCustomer(string memory _userName, string memory _customerData) public {
        require(banks[msg.sender].ethAddress != address(0), "Your are not authorized to create a customer");
        require(customers[_userName].bank == address(0), "Customer is already present");
        customers[_userName].userName = _userName;
        customers[_userName].data = _customerData;
        customers[_userName].bank = msg.sender;
        customers[_userName].upvotes = 0;
        customers[_userName].downvotes = 0;

        customerCount = customerCount + 1;
    }

    function removeRequest(string memory _userName) public {
        require(banks[msg.sender].ethAddress != address(0), "Your are not authorized to remove a request");
        require(requests[_userName].bank != address(0), "Request is not present");
        delete requests[_userName];
    }

    function viewCustomer(string memory _userName) public view returns (Customer memory) {
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        return (customers[_userName]);
    }

    function upvoteCustomer(string memory _userName) public {
        require(banks[msg.sender].ethAddress != address(0), "Your are not authorized to upvote");
        require(customers[_userName].bank != address(0), "Customer is not present");
        customers[_userName].upvotes = customers[_userName].upvotes + 1;

        if (customers[_userName].upvotes > customers[_userName].downvotes && customers[_userName].downvotes < (bankCount/3)) {
            customers[_userName].kycStatus = true;
        }
    }

    function downvoteCustomer(string memory _userName) public {
        require(banks[msg.sender].ethAddress != address(0), "Your are not authorized to downvote");
        require(customers[_userName].bank != address(0), "Customer is not present");
        customers[_userName].downvotes = customers[_userName].downvotes + 1;

        if (customers[_userName].downvotes >= (bankCount/3)) {
            customers[_userName].kycStatus = true;
        }
    }

    function modifyCustomer(string memory _userName, string memory _newcustomerData) public {
        require(banks[msg.sender].ethAddress != address(0), "Your are not authorized to modify customer data");
        require(customers[_userName].bank != address(0), "Customer is not present in the database");
        customers[_userName].data = _newcustomerData;
    }

    function getBankComplaints(address _bankAddress) public view returns (uint256) {
        require(banks[_bankAddress].ethAddress != address(0), "Bank is not present in the database");
        return (banks[_bankAddress].complaintsReported);
    }

    function reportBank(address _bankAddress) public {
        require(banks[msg.sender].ethAddress != address(0), "Your are not authorized to report");
        require(banks[_bankAddress].ethAddress != address(0), "Bank is not present in the database");
        banks[_bankAddress].complaintsReported = banks[_bankAddress].complaintsReported + 1;

        if (banks[_bankAddress].complaintsReported >= (bankCount/3)) {
            banks[_bankAddress].isAllowedToVote = false;
        }
    }


    // Admin Interface

    function addBank(string memory _name, address _ethAddress, string memory _regNumber) public {
        require(admin != msg.sender, "You don't have rights to add a bank");
        require(banks[_ethAddress].ethAddress == address(0), "Bank is already present, please call modifyBank to edit the bank data");
        banks[_ethAddress].name = _name;
        banks[_ethAddress].ethAddress = _ethAddress;
        banks[_ethAddress].regNumber = _regNumber;
        banks[_ethAddress].kycCount = 0;
        banks[_ethAddress].isAllowedToVote = true;
        banks[_ethAddress].complaintsReported = 0;

        bankCount = bankCount + 1;
    }
    
    function modifyBank(address _ethAddress, bool _isAllowedToVote) public {
        require(admin != msg.sender, "You don't have right to modify a bank");
        require(banks[_ethAddress].ethAddress != address(0), "Bank is not present in the database");
        banks[_ethAddress].isAllowedToVote = _isAllowedToVote;
    }


    function removeBank(address _ethAddress) public {
        require(admin != msg.sender, "You don't have right to modify a bank");
        require(banks[_ethAddress].ethAddress != address(0), "Bank is not present in the database");
        delete banks[_ethAddress];

        bankCount = bankCount - 1;
    }  
    
}    


