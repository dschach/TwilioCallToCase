public class Twilio_CallConfirmController {

	public String getTwiML() {
		TwilioTwiML.Response res = new TwilioTwiML.Response();
		
		String theCaseNumber = ApexPages.currentPage().getParameters().get('cNum');
		TwilioTwiML.Say say = new TwilioTwiML.say('Thank you for calling ' + UserInfo.getOrganizationName() + '.');
		say.setVoice('Alice');
		res.append(say);
		
		TwilioTwiML.Say say2 = new TwilioTwiML.say('Your case number is ' + theCaseNumber + '. Please make a note of it.');
		say2.setVoice('Alice');
		res.append(say2);
		TwilioTwiML.Say sayGoodbye = new TwilioTwiML.say('Thank you. Goodbye.');
		sayGoodbye.setVoice('Alice');
		res.append(sayGoodbye);
		res.append(new TwilioTwiML.Hangup());
		return res.toXML();
	}
}