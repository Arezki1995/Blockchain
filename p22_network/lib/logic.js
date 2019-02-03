const NS= 'org.public'

/**
 * Script that handles the logic behind Broadcast transaction
 *@param {org.public.Broadcast} br An instance of broadcast transaction type
 *@transaction
 */
async function broadcastHandler(br) {
  
  	const usersReg = await getParticipantRegistry(NS+'.User');
      
    //make sure the owner exists in the users registry
    const user    = await usersReg.get(br.ownerID);
        
    if(user==undefined)
    {
        throw new Error('Broadcast failed: message ownerID you supplied does not correspond to a network user');
    }
     
    //verify identity
  	if(user.signature!=br.ownerSignature){
    	throw new Error('Broadcast failed: invalid Signature');
    }
  	
    return getAssetRegistry(NS+'.Message').then(function(result) {
             
      	var factory = getFactory();
      	var newMessage = factory.newResource(NS, 'Message', br.newMsgId); 
        //To do later : create systematically an Id
      
        newMessage.title       = br.newMsgTitle;
      	newMessage.content 	   = br.newMsgContent;
      	newMessage.ownerName   = user.userName;
      	newMessage.ownerID     = br.ownerID;
 
        return result.add(newMessage);
     });
}
