// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract FashionStoreOnChain {
    
    address public owner;
    uint256 public productCount;
    uint256 public constant MAX_QUANTITY = 1000;
    uint256 public constant MAX_PRICE = 100 ether;

    struct Product {
        string name;
        uint256 price;
        uint256 quantity;
        bool isActive;
    }
    
    mapping(uint256 => Product) public products;
    mapping(address => mapping(uint256 => uint256)) public purchases;
    
    
    
    event ProductAdded(uint256 indexed productId, string name, uint256 price);
    event ProductUpdated(uint256 indexed productId, uint256 newPrice, uint256 newQuantity);
    event ProductPurchased(address indexed buyer, uint256 indexed productId, uint256 quantity);
    event RefundIssued(address indexed customer, uint256 indexed productId, uint256 amount);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    function addProduct(string memory _name, uint256 _priceInWei, uint256 _quantity) 
        public 
        onlyOwner 
    {
        require(bytes(_name).length > 0, "Name required");
        require(_priceInWei > 0, "Price must be > 0");
        require(_quantity > 0, "Quantity must be > 0");
        
        // Internal checks using assert
        assert(_priceInWei <= MAX_PRICE); // Ensure price is within reasonable limits
        assert(_quantity <= MAX_QUANTITY); // Ensure quantity is within limits
        
        productCount++;
        products[productCount] = Product({
            name: _name,
            price: _priceInWei,
            quantity: _quantity,
            isActive: true
        });
        
        emit ProductAdded(productCount, _name, _priceInWei);
    }

    function updateProduct(uint256 _productId, uint256 _newPrice, uint256 _newQuantity) public onlyOwner {
        Product storage product = products[_productId];
        require(product.isActive, "Product not available");
        require(_newPrice > 0, "Price must be > 0");
        
        // Internal checks using assert
        assert(_productId <= productCount); // Ensure product ID exists
        assert(_newPrice <= MAX_PRICE); // Price sanity check
        assert(_newQuantity <= MAX_QUANTITY); // Quantity sanity check
        
        product.price = _newPrice;
        product.quantity = _newQuantity;
        
        emit ProductUpdated(_productId, _newPrice, _newQuantity);
    }
    
    function purchaseProduct(uint256 _productId, uint256 _quantity) 
        public 
        payable 
    {
        Product storage product = products[_productId];
        require(product.isActive, "Product not available");
        require(_quantity > 0, "Invalid quantity");
        require(product.quantity >= _quantity, "Insufficient stock");
        
        uint256 totalPrice = product.price * _quantity;
        require(msg.value >= totalPrice, "Insufficient payment");
        
        // Internal checks using assert
        assert(product.quantity >= _quantity); // Double check stock
        assert(address(this).balance >= msg.value); // Verify contract balance
        assert(totalPrice / _quantity == product.price); // Check for price calculation overflow
        
        product.quantity -= _quantity;
        purchases[msg.sender][_productId] += _quantity;
        
        // Refund excess payment
        if (msg.value > totalPrice) {
            uint256 refundAmount = msg.value - totalPrice;
            assert(refundAmount < msg.value); // Verify refund amount is valid
            
            (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
            if (!success) {
                revert("Refund failed");
            }
        }
        
        emit ProductPurchased(msg.sender, _productId, _quantity);
    }
    
    function refundProduct(uint256 _productId, uint256 _quantity) 
        public 
    {
        require(_quantity > 0, "Invalid quantity");
        require(purchases[msg.sender][_productId] >= _quantity, "No such purchase");
        
        Product storage product = products[_productId];
        uint256 refundAmount = product.price * _quantity;
        
        // Internal checks using assert
        assert(product.quantity + _quantity <= MAX_QUANTITY); // Prevent quantity overflow
        assert(refundAmount / _quantity == product.price); // Check for refund calculation overflow
        assert(address(this).balance >= refundAmount); // Verify contract has enough funds
        
        purchases[msg.sender][_productId] -= _quantity;
        product.quantity += _quantity;
        
        (bool success, ) = payable(msg.sender).call{value: refundAmount}("");
        if (!success) {
            revert("Refund transfer failed");
        }
        
        emit RefundIssued(msg.sender, _productId, refundAmount);
    }
    
    function withdrawFunds() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        
        // Internal check using assert
        assert(balance <= address(this).balance); // Redundant but safe check
        
        (bool success, ) = payable(owner).call{value: balance}("");
        if (!success) {
            revert("Withdrawal failed");
        }
    }
}