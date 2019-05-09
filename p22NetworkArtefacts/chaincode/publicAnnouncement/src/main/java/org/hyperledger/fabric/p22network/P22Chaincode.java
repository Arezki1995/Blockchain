package org.hyperledger.fabric.p22network;
import org.json.*;
import java.util.List;
import java.util.LinkedHashMap;
import java.io.StringReader;
import org.bouncycastle.util.io.pem.PemReader;
import java.io.IOException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.io.ByteArrayInputStream;
import java.time.Instant;

import com.google.protobuf.ByteString;
import io.netty.handler.ssl.OpenSsl;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hyperledger.fabric.shim.ChaincodeBase;
import org.hyperledger.fabric.shim.ChaincodeStub;

import org.hyperledger.fabric.protos.msp.Identities;
import com.google.protobuf.InvalidProtocolBufferException;

import static java.nio.charset.StandardCharsets.UTF_8;

public class P22Chaincode extends ChaincodeBase {

    private static Log _logger = LogFactory.getLog(P22Chaincode.class);
    private String adminID  = "";
    private String adminName= "";
    private String adminPWD = "";
    private String adminAff = "";

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // HELPER FUNCTION TO CREATE USER DATA STRUCTURE
    JSONObject makeUser(String userName, String pwd, String role, String affiliation, String certificate){
        //CREATE WRAPPER USER JSON OBJECT
        JSONObject user = new JSONObject();

        //CREATE IDENTITY SECTION
        JSONObject identity = new JSONObject();
        identity.put("CERT",  certificate);
        identity.put("ROLE",  role);
        identity.put("AFFIL", affiliation );
        identity.put("PWD",   pwd);
        identity.put("NAME",  userName);
        
        //For msg data
        JSONArray msgs = new JSONArray();
        user.put("Messages",msgs);
        user.put("Identity",identity);

        return user;
    }    
    

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // HELPER FUNCTION TO CREATE MESSAGE DATA STRUCTURE
    JSONObject makeMsg(String Id, String title, String content, String TimeStamp){
        //CREATE WRAPPER USER JSON OBJECT
        JSONObject msg = new JSONObject();
        msg.put("TIME",TimeStamp);
        msg.put("CONTENT",TimeStamp);
        msg.put("TITLE",TimeStamp);
        msg.put("ID",Id);
        return msg;
    }    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    @Override
    public Response init(ChaincodeStub stub) {

        _logger.info("========================================================> Init");
        String func = stub.getFunction();
        if (!func.equals("init")) {
            return newErrorResponse("function other than init is not supported");
        }
        List<String> args = stub.getParameters();

        if (args.size() != 4) {
            return newErrorResponse("Incorrect number of arguments. Expecting Id, UserName and UserMinistry");
        }

            adminID  = args.get(0);
            adminName= args.get(1);
            adminPWD = args.get(2);
            adminAff = args.get(3);

            //GET CERTIFICATE
            byte[] a = stub.getCreator(); 
            String initCert = new String(a);
            _logger.info("Admin certificate:"+initCert);

            JSONObject adminAccount= makeUser(adminName, adminPWD, "Admin", adminAff ,initCert);
            stub.putStringState(adminID, adminAccount.toString());

        _logger.info("========================================================> Init OK");
        return newSuccessResponse();        
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    @Override
    public Response invoke(ChaincodeStub stub) {
        try {
            _logger.info("========================> Invoke function called");
            String func = stub.getFunction();
            List<String> params = stub.getParameters();

            if (func.equals("addUser")) {
                return addUser(stub, params);
            }
            if (func.equals("delUser")) {
                return delUser(stub, params);
            }
            if (func.equals("queryUser")) {
                return queryUser(stub, params);
            }
            if (func.equals("broadcastMsg")) {
                return broadcastMsg(stub, params);
            }
            if (func.equals("queryUserMsgs")) {
                return queryUserMsgs(stub, params);
            }
            return newErrorResponse("Invalid invoke function name. Expecting one of: [addUser, delUser, queryUser, broadcastMsg, queryUserMsgs]");
        } catch (Throwable e) {
            return newErrorResponse(e);
        }
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // create a chaincode user
    private Response addUser(ChaincodeStub stub, List<String> args) {
        _logger.info("========================> addUser Called");
        if (args.size() != 6) {
            return newErrorResponse("Incorrect number of arguments. Expecting: Id, UserName, UserMinistry, UserPWD, adminID, adminPWD");
        }
                
        if ( !(args.get(4).equals(adminID)) || !(args.get(5).equals(adminPWD)) ) {
            return newErrorResponse(String.format("Error: YOU DO NOT HAVE ADMIN RIGHTS TO CREATE USERS"));
        }   
        

        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        //DECODE THE CERTIFICATE OF THE INVOKING CLIENT TO DECIDE IF HE IS OR NOT AN ADMIN TO CREATE A USER
        //THIS IS JUST FOR ADVANCED ACCESS CONTROL 

                    byte[] a = stub.getCreator(); 
                    //Convert byte[] to String
                    String invokerCert = new String(a);
                    _logger.info("========================> addUser: IDENTITY OF CALLER\n"+invokerCert);
                    
                    try {
                        Identities.SerializedIdentity identity = Identities.SerializedIdentity.parseFrom(stub.getCreator()); 
                        StringReader reader = new StringReader(identity.getIdBytes().toStringUtf8()); 
                        PemReader pr = new PemReader(reader); 
                        byte[] x509Data=null;
                        try{
                            x509Data = pr.readPemObject().getContent();
                        }catch(IOException e){
                            e.printStackTrace();
                        }

                        CertificateFactory factory=null;
                        try {
                            factory = CertificateFactory.getInstance("X509"); 
                        } catch (Exception e) {
                            e.printStackTrace();
                        }    
                        
                        X509Certificate certificate=null;
                        try {
                            certificate = (X509Certificate) factory.generateCertificate(new ByteArrayInputStream(x509Data));
                        } catch (Exception e) {
                            e.printStackTrace();
                        } 
                           
                        _logger.info("========================> addUser: CERTIFICATE CONTENT OF CALLER\n"+ certificate.toString());

                    } catch (InvalidProtocolBufferException e) {
                        e.printStackTrace();
                    }
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
        String id           = args.get(0);
        String userName     = args.get(1);
        String userMinistry = args.get(2);
        String userPwd      = args.get(3);
        String userRole     = "Client";
        
        

        //VERIFY EXISTANCE
        String val	= stub.getStringState(id);
        _logger.info("========================= > verify existence:{"+val+"}");

        /* 
        if (val.length()<=1) {
            return newErrorResponse(String.format("Error: user with Id: %s already exists", id));
        }   
        */

        //INITIATE USER
        JSONObject user = makeUser(userName, userPwd, "Client", userMinistry, "null");
            


        //ADD IT TO LEDGER
        _logger.info("=========ToRemove=========> user.toString(): " + user.toString());
        stub.putStringState(id, user.toString());
    
        //return newErrorResponse();
        _logger.info("Response: User added Successfully");
        return newSuccessResponse("User added Successfully:\n", ByteString.copyFrom(user.toString() , UTF_8).toByteArray());
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Deletes an entity from state
    private Response delUser(ChaincodeStub stub, List<String> args) {
        if (args.size() != 3) {
            return newErrorResponse("Incorrect number of arguments. Expecting 3: id, AdminID, AdminPWD");
        }

        // VERIFY IT IS FROM ADMIN
        if ( !(args.get(1).equals(adminID)) || !(args.get(2).equals(adminPWD)) ) {
            return newErrorResponse(String.format("Error: YOU DO NOT HAVE ADMIN RIGHTS TO DELETE USERS"));
        }   

        //DO NOT ALLOW ADMIN TO DELETE ADMIN
        if ( (args.get(0).equals(adminID)) ) {
            return newErrorResponse(String.format("Error: CANNOT DELETE ADMIN"));
        } 

        String key = args.get(0);

        String val	= stub.getStringState(key);
        if (val == null) {
            return newErrorResponse(String.format("Error: use with id %s doesn't exit", key));
        }
        
        // Delete the key from the state in ledger
        stub.delState(key);
        return newSuccessResponse();
    }

    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    // Find a user entry in storage
    private Response queryUser(ChaincodeStub stub, List<String> args) {
        if (args.size() != 1) {
            return newErrorResponse("Incorrect number of arguments. Expecting name of the person to query");
        }
        String key = args.get(0);

        String val	= stub.getStringState(key);

        if (val == null) {
            return newErrorResponse(String.format("Error: state for %s is null", key));
        }
    
        JSONObject user = new JSONObject(val);
        JSONObject identity =( (JSONObject) user.get("Identity"));
        String name  = identity.get("NAME").toString();
        String affil = identity.get("AFFIL").toString();
        String role  = identity.get("ROLE").toString();
        
        JSONArray messages = (JSONArray) user.get("Messages");
        String result = "{\nNAME: " + name + ",\nROLE: " + role + ",\nAFFIL: "+ affil + ",\n"+ messages.toString() + "}"; 
        return newSuccessResponse(val, ByteString.copyFrom(result, UTF_8).toByteArray());
    }

    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    ///////////////////////////////// broadcast a Message  ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    private Response broadcastMsg(ChaincodeStub stub, List<String> args) {
        _logger.info("broadcast launched");
        if (args.size() != 4) {
            return newErrorResponse("Incorrect number of arguments. Expecting: UserId , userPWD,  MsgTitle , MsgContent");
        }
        String id         = args.get(0);
        String UserPWD    = args.get(1);
        String msgTitle   = args.get(2);
        String msgContent = args.get(3);

        
   

        //VERIFY EXISTANCE
        String value = stub.getStringState(id);
        _logger.info("[broadcastMsg] id search string result:"+value);

        if(value==null){
            return newErrorResponse(String.format("\nError: USER WITH ID [%s] DOES NOT EXIST\n", id));
        }else{
            //JSONify the String
            JSONObject user = new JSONObject(value);
            String internalPwd = ((JSONObject) user.get("Identity")).get("PWD").toString();
            if(!internalPwd.equals(UserPWD)){
                return newErrorResponse(String.format("Error: WRONG PASSWORD. NO RIGHTS TO PUBLISH"));
            }

            //Adding the msg to the JSON array of messages representing the list broadcasted by this user
                
                //Creating message
                Instant time = stub.getTxTimestamp();

                JSONObject newMsg = makeMsg(stub.getTxId() , msgTitle, msgContent, time.toString());
                
                //Add Current msg to user's messages array
                user.append("Messages", newMsg);

            //ADD IT TO LEDGER
            stub.putStringState(id, user.toString());
        
            //return newErrorResponse();
            _logger.info("Response: Message broadcasted Successfully");
            return newSuccessResponse("Message broadcasted Successfully:\n", ByteString.copyFrom(user.toString(), UTF_8).toByteArray());
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    //////////////////////        Get Messages of a given User through his Id      ////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////

    private Response queryUserMsgs(ChaincodeStub stub, List<String> args) {
        if (args.size() != 1) {
            return newErrorResponse("Incorrect number of arguments. Expecting : UserId");
        }
        String userID = args.get(0);

        String val	= stub.getStringState(userID);
        if (val == null) {
            return newErrorResponse(String.format("\nError: USER WITH ID [%s] DOES NOT EXIST\n", userID));
        }else{
            //JSONify the String
            JSONObject user = new JSONObject(val);
            String messages = user.get("Messages").toString();
            return newSuccessResponse(val, ByteString.copyFrom(messages, UTF_8).toByteArray());
        }
    }


    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////   MAIN   ////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////
    public static void main(String[] args) {
        System.out.println("OpenSSL avaliable: " + OpenSsl.isAvailable());
        new P22Chaincode().start(args);
    }
}
