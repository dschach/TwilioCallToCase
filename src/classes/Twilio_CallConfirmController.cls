public class Twilio_CallConfirmController {


	public String getTwiML() {
		TwilioTwiML.Response res = new TwilioTwiML.Response();
		
		String theCaseNumber = ApexPages.currentPage().getParameters().get('cNum');
		theCaseNumber = EncodingUtil.urlDecode(theCaseNumber, 'UTF-8');
		
		TwilioTwiML.Say say = new TwilioTwiML.say('Thank you for calling ' + UserInfo.getOrganizationName() + '.');
		say.setVoice('Alice');
		res.append(say);
		
		TwilioTwiML.Say say2 = new TwilioTwiML.say('Your case number is ' + theCaseNumber + '. Please make a note of it.');
		say2.setVoice('Alice');
		res.append(say2);
		
		if (ApexPages.currentPage().getParameters().containsKey('theText')) {
                        String theText = ApexPages.currentPage().getParameters().get('theText');
			TwilioTwiML.Say say3 = new TwilioTwiML.say('You said ' + EncodingUtil.urlDecode(theText, 'UTF-8'));
			say3.setVoice('Alice');
			res.append(say3);
		}
		
		TwilioTwiML.Say sayGoodbye = new TwilioTwiML.say('Thank you. Goodbye.');
		sayGoodbye.setVoice('Alice');
		res.append(sayGoodbye);
		res.append(new TwilioTwiML.Hangup());
		return res.toXML();
	}
}