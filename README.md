# WTestApp

The user has the follow features available:
- Download and parse the CSV file to the application
- Search for a specific address 
- Remove all the information available in the application

This application starts to download a CSV file to a document directory, then it will be parsed all the CSV data into a list of addresses (num_cod_postal, ext_cod_postal and desig_postal fields).
Once we got the data, it was used Core Data to save all the information into a database. The next time the user logins doesn't have to wait too long until the data is shown. 

While all this procedure is happening the user has the opportunity to know how is the parsing loading process.

Now the user can start to search for a specific address. Notice that the last 6 searching examples asked in the test are not available. Despite that all the search requirements described are being supported. The search is being made directly to the database.

Finally, the user has the possibility to delete all the data from the application and the database - through the right bar item - and can do the opposite - download all the data - clicking on the left bar item. This was created so the user doesn't have to delete the application every time he / she want to test the first loading.

Dependencies used: 
- Alamofire
- CSVImporter

To get the application running it is only needed to have CocoaPods installed and once you get to the project folder, through the command line, only is needed to run pod install.
