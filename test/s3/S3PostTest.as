package s3 {
  
  import flexunit.framework.TestCase;
  import flexunit.framework.TestSuite;
  
  import org.httpclient.*;
  import org.httpclient.http.*;
  import org.httpclient.events.*;
  import org.httpclient.http.multipart.*;
  
  import com.adobe.net.*;
  
  import flash.utils.ByteArray;
  import flash.events.Event;
  import flash.events.ErrorEvent;
  
  public class S3PostTest extends TestCase {
    
    public function S3PostTest(methodName:String):void {
      super(methodName);
    }
    
    public static function suite():TestSuite {      
      var ts:TestSuite = new TestSuite();
      ts.addTest(new S3PostTest("testPost"));
      return ts;
    }
    
    /**
     * Test post with multipart form data.
     */
    public function testPost():void {
      var client:HttpClient = new HttpClient();
            
      var bucketName:String = "http-test-post";
      var objectName:String = "test-post.txt";
      
      var uri:URI = new URI("http://" + bucketName + ".s3.amazonaws.com/" + objectName);
      var contentType:String = "text/plain";
      
      var accessKey:String = "0RXZ3R7Y034PA8VGNWR2";      
      var postOptions:S3PostOptions = new S3PostOptions(bucketName, objectName, accessKey, { contentType: contentType });      
      var policy:String = postOptions.getPolicy();
      
      // This is how I got the signature below
      /*var secretAccessKey:String = "<SECRET>";      
      var signature:String = postOptions.getSignature(secretAccessKey, policy);
      Log.debug("signature=" + signature);*/
      var signature:String = "t2BddItEPDtljgVaQRxBkNL1qGM="; 
      
      var data:ByteArray = new ByteArray();
      data.writeUTFBytes("This is a test");
      data.position = 0;
      
      var multipart:Multipart = new Multipart([ 
        new Part("key", objectName), 
        new Part("Content-Type", contentType),
        new Part("AWSAccessKeyId", accessKey),
        new Part("Policy", policy),
        new Part("Signature", signature),
        new Part("file", data, contentType)
      ]);
      
      var response:HttpResponse = null;
            
      client.listener.onComplete = addAsync(function():void {
        assertNotNull(response);
      }, 20 * 1000);
      
      client.listener.onStatus = function(event:HttpStatusEvent):void {
        response = event.response;
        Log.debug("Response: " + response);
        assertTrue(response.isSuccess);
      };
      
      client.listener.onError = function(event:ErrorEvent):void {
        fail(event.text);
      };
      
      client.listener.onData = function(event:HttpDataEvent):void {
        Log.debug(event.readUTFBytes());
      };
      
      client.postMultipart(uri, multipart);
    }    
    
  }
  
}