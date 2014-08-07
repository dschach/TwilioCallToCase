twilioCallToCase
================

Use Twilio (requires the Apex helper library) to leave a voicemail, which is transcribed and made into a Case. Confirmations included.

You must install the Twilio Salesforce library first and set up your Twilio account.

Create a Force.com Site and add the three pages in this repository to the site.

Sign up for a Twilio number and set the call URL to the 'site base URL' + '/CallToCase'.

Call the number you created and see what happens:

1. Case created
2. Assignment rules followed
3. SMS notification to new Case Owner
4. SMS notification to caller
5. Call to caller with transcription read back to caller

Enjoy!