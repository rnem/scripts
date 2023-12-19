'#####################################################
'# Created by Roger Nem                              #
'# History:                                          #
'# v0.001  - Roger Nem - First Version               #
'#####################################################

Set myMail=CreateObject("CDO.Message")
myMail.Subject="Test Email"
myMail.From="user@domain.com"
myMail.To="user@domain.com"
myMail.Bcc="user@domain.com"
myMail.Cc="user@domain.com"
myMail.TextBody= "This is a test message."
myMail.Send
set myMail=nothing
