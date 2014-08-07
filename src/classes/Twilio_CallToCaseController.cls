public with sharing class Twilio_CallToCaseController {

	public String getTwiML() {
		TwilioTwiML.Response res = new TwilioTwiML.Response();
		
		if (ApexPages.currentPage().getParameters().get('RecordingURL') != null) {
			/*
			    Map<String, String> pageParams = ApexPages.currentPage().getParameters();
			    Set<String> keys = ApexPages.currentPage().getParameters().keyset();
			    List<String> keylist = new List<String>();
			    keylist.addAll(keys);
			
			    for (String s : keylist) {
			    System.debug(s + ' | ' + pageParams.get(s));
			    }
			*/
			
			TwilioTwiML.Say sayGoodbye = new TwilioTwiML.say('Thank you. Goodbye.');
			sayGoodbye.setVoice('Alice');
			res.append(sayGoodbye);
			res.append(new TwilioTwiML.Hangup());
			return res.toXML();
		}
		
		TwilioTwiML.Say say = new TwilioTwiML.say('Please leave a message for our support team.');
		say.setVoice('Alice');
		res.append(say);
		TwilioTwiML.Say say2 = new TwilioTwiML.say('Press pound to end, or just hang up.');
		say2.setVoice('Alice');
		res.append(say2);
		
		TwilioTwiML.Record rec = new TwilioTwiML.Record();
		rec.setTranscribeCallback(Page.TranscriptionHandler.getURL());
		rec.setTranscribeCallback('/TranscriptionHandler');
		rec.setTranscribe(true);
		rec.setMaxLength(120);
		rec.setFinishOnKey('#');
		res.append(rec);
		
		res.append(new TwilioTwiML.Hangup());
		
		return res.toXML();
		
	}
}