pragma solidity ^0.4.9;

contract RPS{
    address j1;
    address j2;
    enum Coup {Null, Rock, Paper, Scissors, Spock, Lizard}
    bytes32 c1Hash;
    Coup c2;
    uint256 stake;
    uint256 TIMEOUT = 5 minutes;
    uint256 lastAction;
    
    
    function RPS(bytes32 _c1Hash, address _j2) payable {
        stake = msg.value; // La mise correspond à la quantité d'ethers envoyés.
        j1=msg.sender;
        j2=_j2;
        c1Hash=_c1Hash;
        lastAction=now;
    }
    
    function play(Coup _c2) payable {
        require(c2==Coup.Null); // J2 has not played yet.
        require(msg.value==stake); // J2 has paid the stake.
        require(msg.sender==j2); // Only j2 can call this function.
            
        c2=_c2;
        lastAction=now;
    }
    
    function solve(Coup c1, uint256 nombreAleatoire) {
        require(c2!=Coup.Null); // J2 must have played.
        require(msg.sender==j1); // J1 can call this.
        require(keccak256(c1,nombreAleatoire)==c1Hash); // Verify the value is the commited one.
        
        // If j1 or j2 throws at fallback it won't get funds and that is his fault.
        // Despite what the warning says, we should not use transfer as a throwing fallback would be able to block the contract, in case of tie.
        if (win(c1,c2))
            j1.send(2*stake);
        else if (win(c2,c1))
            j2.send(2*stake);
        else {
            j1.send(stake);
            j2.send(stake);
        }
        stake=0;
    }
    
    // Let j2 get the funds back if j1 did not play.
    function j1Timeout() {
        require(c2!=Coup.Null); // J2 already played.
        require(now > lastAction + TIMEOUT); // Timeout time has passed.
        j2.send(2*stake);
        stake=0;
    }
    
    // Let j1 take back the funds if j2 never play.
    function j2Timeout() {
        require(c2==Coup.Null); // J2 has not played.
        require(now > lastAction + TIMEOUT); // Timeout time has passed.
        j1.send(stake);
        stake=0;
    }
    
    
    function win(Coup c1, Coup c2) constant returns (bool) {
        if (c1 == c2)
            return false; // They played the same so no winner.
        else if (c1==Coup.Null)
            return false; // They did not play.
        else if (uint(c1)%2==uint(c2)%2) 
            return (c1<c2);
        else
            return (c1>c2);
    }
    
}

contract Hasher{
    // Give the commitement.
    // Must only be called locally.
    function hash(uint8 c, uint256 nonce) constant returns(bytes32) {
        return keccak256(c,nonce);
    }
}
