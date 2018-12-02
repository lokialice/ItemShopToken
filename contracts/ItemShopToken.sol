pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

/* 
`* is owned
*/
contract owned {

    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function ownerTransferOwnership(address newOwner)
        onlyOwner
    {
        owner = newOwner;
    }

}

/* 
* safe math
*/
contract DSSafeAddSub {

    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b >= a);
    }
    
    function safeAdd(uint a, uint b) internal returns (uint) {
        if (!safeToAdd(a, b)) throw;
        return a + b;
    }

    function safeToSubtract(uint a, uint b) internal returns (bool) {
        return (b <= a);
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        if (!safeToSubtract(a, b)) throw;
        return a - b;
    } 

}


contract ItemShopToken is owned, DSSafeAddSub {

    /* check address */
    modifier onlyBy(address _account) {
        if (msg.sender != _account) throw;
        _;
    }    

    /* struct */
    struct Game{
        bytes32 name;
    }
    
    struct ItemGame{
        address gameID;
        bytes32 name;
        uint price;
    }
    
    struct ItemOwner{
        ItemGame item;
        bool isUserSale;
        bool isMerchantSale;
        bool statusOwner;
        
    }
    
    /* vars */
    string public standard = 'Token 1.0';
    string public name = "ItemShop";
    string public symbol = "IST";
    uint8 public decimals = 18;
    uint public totalSupply = 25000000000000000000000000; 

    address public priviledgedAddress; 
    ItemShopToken public ist;
    bool public tokensFrozen;
    mapping (address => Game) public games;
    mapping (bytes32 => ItemGame) public itemGames;
    mapping (address => ItemOwner) public itemOwners;

    /* map balances */
    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;  

    /* events */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event LogTokensFrozen(bool indexed Frozen);    
    event GameLog(bytes32 name, address gameOwner);
    event ChangePriceLog(bytes32 idx, uint priceItem);
    event AddItemGameLog(bytes32 idx, address gameId, bytes32 nameItem, uint priceItem);
    event OrderItemFromMerchantLog(bytes32 idx, uint priceItem, address buyer, address merchant);
    event OrderItemFromMerchantUserLog(bytes32 idx, uint priceItem, address fromUser, address buyer);
    
    /*
    *  @notice sends all tokens to msg.sender on init    
    */  
    function ItemShopToken(){
        /* send creator all initial tokens 25,000,000 */
        balanceOf[msg.sender] = 25000000000000000000000000;
        /* tokens are not frozen */  
        tokensFrozen = false;      
        priviledgedAddress = msg.sender;
        ist = this;
    }  

    /*
    *  @notice public function    
    *  @param _to address to send tokens to   
    *  @param _value number of tokens to transfer 
    *  @returns boolean success         
    */     
    function transfer(address _to, uint _value) public
        returns (bool success)    
    {
        if (balanceOf[msg.sender] < _value) return false;                   /* check if the sender has enough */
        if (balanceOf[_to] + _value < balanceOf[_to]) return false;         /* check for overflows */              
        balanceOf[msg.sender] -=  _value;                                   /* subtract from the sender */
        balanceOf[_to] += _value;                                           /* add the same to the recipient */
        Transfer(msg.sender, _to, _value);                                  /* notify anyone listening that this transfer took place */
        return true;
    }      

    /*
    *  @notice public function    
    *  @param _from address to send tokens from 
    *  @param _to address to send tokens to   
    *  @param _value number of tokens to transfer     
    *  @returns boolean success      
    *  another contract attempts to spend tokens on your behalf
    */       
    function transferFrom(address _from, address _to, uint _value) public
        returns (bool success) 
    {                
        if (balanceOf[_from] < _value) return false;                        /* check if the sender has enough */
        if (balanceOf[_to] + _value < balanceOf[_to]) return false;         /* check for overflows */                
        if (_value > allowance[_from][msg.sender]) return false;            /* check allowance */
        balanceOf[_from] -= _value;                                         /* subtract from the sender */
        balanceOf[_to] += _value;                                           /* add the same to the recipient */
        allowance[_from][msg.sender] -= _value;                             /* reduce allowance */
        Transfer(_from, _to, _value);                                       /* notify anyone listening that this transfer took place */
        return true;
    }        
 
    /*
    *  @notice public function    
    *  @param _spender address being granted approval to spend on behalf of msg.sender
    *  @param _value number of tokens granted approval for _spender to spend on behalf of msg.sender    
    *  @returns boolean success      
    *  approves another contract to spend some tokens on your behalf
    */      
    function approve(address _spender, uint _value) public
        returns (bool success)
    {
        /* set allowance for _spender on behalf of msg.sender */
        allowance[msg.sender][_spender] = _value;

        /* log event about transaction */
        Approval(msg.sender, _spender, _value);        
        return true;
    } 
  
    /*        
    *  @notice address restricted function 
    *  crowdfund contract calls this to burn its unsold coins 
    */     
    function priviledgedAddressBurnUnsoldCoins() public
        /* only crowdfund contract can call this */
        onlyBy(priviledgedAddress)
    {
        /* totalSupply should equal total tokens in circulation */
        totalSupply = safeSub(totalSupply, balanceOf[priviledgedAddress]); 
        /* burns unsold tokens from crowdfund address */
        balanceOf[priviledgedAddress] = 0;
    } 

    /*
    *  @notice owner restricted function
    *  @param _newPriviledgedAddress the address
    *  only this address can burn unsold tokens
    *  transfer tokens only by priviledgedAddress during crowdfund or reward phases
    */      
    function ownerSetPriviledgedAddress(address _newPriviledgedAddress) public 
        onlyOwner
    {
        priviledgedAddress = _newPriviledgedAddress;
    }   
    
    function addGame(bytes32 nameOfGame, address gameOwner) public onlyBy(priviledgedAddress){
        games[gameOwner] = Game({
            name:nameOfGame
        });
        emit GameLog(nameOfGame, gameOwner);
    }
    
    function addItemGame(bytes32 idx, address gameId, bytes32 nameItem, uint priceItem) public onlyBy(priviledgedAddress){
        itemGames[idx] = ItemGame({
            gameID: gameId,
            name:nameItem,
            price:priceItem
        });
        
        itemOwners[gameId] = ItemOwner({
            item: ItemGame({
                gameID: gameId,
                name:nameItem,
                price:priceItem
            }),
            isUserSale: false,
            isMerchantSale: true,
            statusOwner: true
        });
        emit AddItemGameLog (idx, gameId, nameItem, priceItem);
    }
    
    function changePriceItem(bytes32 idx, uint priceItem) public onlyBy(priviledgedAddress) {
        ItemGame storage item = itemGames[idx];
        item.price = priceItem;
        emit ChangePriceLog(idx, priceItem);
    }
    
    function changeUserSaleStatus(bytes32 idx, bool status) {
        ItemOwner storage itemOwner = itemOwners[msg.sender];
        itemOwner.isUserSale = status;
    }
    
    function changeMerchantSaleStatus(bytes32 idx, bool status) {
        ItemOwner storage itemOwner = itemOwners[msg.sender];
        itemOwner.isMerchantSale = status;
    }
    
    function orderItemFromMerchant(bytes32 idx, uint priceItem){
        require(balanceOf[msg.sender] > 0);
        ItemGame storage item = itemGames[idx];
        ItemOwner storage itemOwner = itemOwners[item.gameID];
        
        require(item.price == priceItem);
        require(itemOwner.statusOwner);
        require(itemOwner.isMerchantSale);
        
        if(ist.transferFrom(msg.sender, item.gameID, priceItem)){
        
            itemOwners[msg.sender] = ItemOwner({
                item: item,
                isUserSale: false,
                isMerchantSale: true,
                statusOwner: true
            });
    
            emit OrderItemFromMerchantLog(idx, priceItem, msg.sender, item.gameID);
        }
        
    }
    
    function orderItemFromUser(bytes32 idx, uint priceItem, address fromUser){
        require(balanceOf[msg.sender] > 0);
        ItemGame storage item = itemGames[idx];
        ItemOwner storage itemOwnerFrom = itemOwners[item.gameID];
        
        require(item.price == priceItem);
        require(itemOwnerFrom.isUserSale);
        require(itemOwnerFrom.statusOwner);
        
        uint fee = priceItem * 2 / 100;
        
        if(ist.transferFrom(msg.sender, priviledgedAddress, fee) && ist.transferFrom(msg.sender, fromUser, priceItem - fee)){
            itemOwnerFrom.statusOwner = false;
            itemOwners[fromUser] = ItemOwner({
                item: item,
                isUserSale: false,
                isMerchantSale: true,
                statusOwner: true
            });
            emit OrderItemFromMerchantUserLog(idx, priceItem, fromUser, msg.sender);
        }
        
    }
    
    function checkItemOwner(bytes32 idx, address owner) public returns (ItemOwner itemOwner) {
        itemOwner = itemOwners[owner];
        return itemOwner;
    }
    
}