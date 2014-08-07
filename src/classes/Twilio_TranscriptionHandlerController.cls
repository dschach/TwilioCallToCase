public with sharing class Twilio_TranscriptionHandlerController {


	static TwilioAccount t_account = TwilioAPI.getDefaultAccount();
	
	public PageReference onLoad() {
		Map <String, String> params = ApexPages.currentPage().getParameters();
		
		/*
		    System.debug('We are in the onLoad method of the TranscriptionHandler.');
		
		    Map<String, String> pageParams = ApexPages.currentPage().getParameters();
		    Set<String> keys = ApexPages.currentPage().getParameters().keyset();
		    List<String> keylist = new List<String>();
		    keylist.addAll(keys);
		
		    for (String s : keylist) {
		    System.debug(s + ' | ' + pageParams.get(s));
		    }
		*/
		
		String caseDescription = params.get('TranscriptionText');
		String fromNumber = params.get('From');
		
		Contact c = findPerson(fromNumber);
		
		Case ca = createCase(c, params);
		
		if (ca != null) {
			ca = [SELECT CaseNumber, Description, OwnerId FROM Case WHERE Id = :ca.Id LIMIT 1];
			User u = [SELECT Id, MobilePhone FROM User WHERE Id = :ca.OwnerId LIMIT 1];
			System.debug('FROM: ' + params.get('Called'));
			System.debug('TO: ' + u.MobilePhone);
			sendSMS(params.get('Called'), u.MobilePhone, 'You have a new Case: ' + ca.CaseNumber);
			sendSMS(params.get('Called'), params.get('From'), 'Case ' + ca.CaseNumber + ' received.');
			callbackCaseConfirm(params.get('Called'), params.get('From'), ca.CaseNumber, ca.Description);
		}
		
		return null;
	}
	
	@future(callout = true)
	public static void callbackCaseConfirm(String fromNumber, String toNumber, String theCaseNum, String theVM) {
	
		String myNum = theCaseNum;
		Integer myNumLength = myNum.length();
		
		List<String> chars = new List<String>();
		
		for (Integer i = 0; i < myNumLength; i++) {
			chars.add(myNum.substring(i, i + 1));
		}
		
		System.debug('chars: ' + chars);
		
		
		String urlNum = String.join(chars, ' ');
		System.debug('urlNum: ' + urlNum);
		urlNum = EncodingUtil.urlEncode(urlNum, 'UTF-8');
		System.debug('urlNum: ' + urlNum);
		/*
		    System.debug('CALLING: ' + toNumber);
		    System.debug('CASE: ' + theCaseNum + ' - ' + urlNum);
		*/
		
		String theURL = 'http://twiliodev1-developer-edition.na17.force.com/CaseConfirmCall?cNum=' + urlNum;
		if(!String.isEmpty(theVM)){
			if(theVM.length() > 2000){
				theVM = theVM.left(2000);
			}
			theURL += '&theText=' + EncodingUtil.urlEncode(theVM, 'UTF-8');
		}
		
		Map<String, String> params = new Map<String, String>();
		params.put('To', toNumber);
		params.put('From', fromNumber);
		// ### Todo: Replace this URL with your site URL! ###
		params.put('Url', theURL);
		TwilioCall call = t_account.getCalls().create(params);
	}
	
	@future(callout = true)
	public static void sendSMS(String fromNumber, String toNumber, String message) {
		System.debug('Twilio Account: ' + t_account);
		
		System.debug('FROM ' + fromNumber);
		System.debug('TO ' + toNumber);
		System.debug('MESSAGE ' + message);
		Map<String, String> params = new Map<String, String> {
			'From' => fromNumber,
			'To' => toNumber,
			'Body' => message
		};
		
		TwilioSms sms = t_account.getSmsMessages().create(params);
		System.debug('Sent SMS SID: ' + sms.getSid());
	}
	
	public static Case createCase(Contact theContact, Map<String, String> t_params) {
		Case c = new Case();
		c.Description = t_params.get('TranscriptionText');
		
		if (theContact == null) {
			c.SuppliedPhone = t_params.get('From');
		}
		else {
			c.ContactId = theContact.Id;
			c.AccountId = theContact.AccountId;
		}
		
		c.Origin = 'Voicemail';
		c.Subject = 'Voicemail case';
		c.Recording_URL__c = t_params.get('RecordingUrl');
		c.VoicemailId__c = t_params.get('CallSid');
		AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
		c.setOptions(dmlOpts);
		
		if (c.Description != '(blank)' && t_params.get('RecordingURL') != null) {
			insert c;
			return c;
		}
		
		return null;
	}
	
	
	private static Contact findPerson(String fromNumber) {
		Contact r;
		Id personId;
		String fromPhone = fromNumber;
		
		if (fromPhone != null) {
			// remove the country prefix for Phone field search
			if (fromPhone.startsWith('+1'))
			{ fromPhone = fromPhone.substring(2); }
			
			system.debug('FromPhone: ' + fromPhone);
			// search Lead and Contact phone number fields
			List<List<SObject>> results = [FIND :fromPhone IN Phone FIELDS
										   RETURNING Contact(Id, AccountId, Phone)
										   LIMIT 1];
										   
			// extract the owner phone if there’s a match
			if (!results[0].isEmpty()) {
				r = (Contact)results[0][0];
			}
			
			return r;
		}
		
		return null;
	}
	
	public String getTwiML() {
		System.debug('In getTwiML');
		System.debug('Params: ' + ApexPages.currentPage().getParameters());
		
		TwilioTwiML.Response res = new TwilioTwiML.Response();
		
		// Included are the parameters sent by Twilio, in case we want to do something here.
		// But we don't - we just do everything in the onLoad() method and return empty TwiML
		/*
		    Parameter   Description
		    TranscriptionSid    The unique 34 character ID of the transcription.
		    TranscriptionText   Contains the text of the transcription.
		    TranscriptionStatus The status of the transcription attempt: either 'completed' or 'failed'.
		    TranscriptionUrl    The URL for the transcription's REST API resource.
		    RecordingSid    The unique 34 character ID of the recording from which the transcription was generated.
		    RecordingUrl    The URL for the transcription's source recording resource.
		    CallSid A unique identifier for this call, generated by Twilio.
		    AccountSid  Your Twilio account id. It is 34 characters long, and always starts with the letters AC.
		    From    The phone number or client identifier of the party that initiated the call. Phone numbers are formatted with a '+' and country code, e.g. +16175551212 ([E.164][e164] format). Client identifiers begin with the client: URI scheme; for example, for a call from a client named 'tommy', the From parameter will be client:tommy.
		    To  The phone number or client identifier of the called party. Phone numbers are formatted with a '+' and country code, e.g. +16175551212 ([E.164][e164] format). Client identifiers begin with the client: URI scheme; for example, for a call to a client named 'jenny', the To parameter will be client:jenny.
		    CallStatus  A descriptive status for the call. The value is one of queued, ringing, in-progress, completed, busy, failed or no-answer. See the CallStatus section for more details.
		    ApiVersion  The version of the Twilio API used to handle this call. For incoming calls, this is determined by the API version set on the called number. For outgoing calls, this is the API version used by the outgoing call's REST API request.
		    Direction   A string describing the direction of the call. inbound for inbound calls, outbound-api for calls initiated via the REST API or outbound-dial for calls initiated by a <Dial> verb.
		    ForwardedFrom   This parameter is set only when Twilio receives a forwarded call, but its value depends on the caller's carrier including information when forwarding. Not all carriers support passing this information.
		*/
		return res.toXML();
	}
}