# CyberDefenders CTF

## Intel101

## Setup

1. Download file from https://cyberdefenders.org/blueteam-ctf-challenges/enroll/38 (pass: cyberdefenders.org)

## Questions

1. Who is the Registrar for jameskainth.com?
2. You get a phone call from this number: 855-707-7328, they were previously known by another name? (No spaces between words)
3. What is the Zoom meeting id of the British Prime Ministers Cabinet Meeting?
4. What Percentage of full-time degree-seeking freshmen from the fall of 2018 re-enrolled to Champlain in the fall of 2019?
5. Champlain College Has A Public Excel Sheet Listing Addresses Of Campus Locations Available on The Internet, what’s the SHA256 hash of the excel file?
6. In 1998 specifically on February 12th, Champlain was planning on adding an exciting new building to its campus. Back then, it was called “The Information Commons”. Can you find a picture of what the inside would look like? Upload the sha256 hash here.
7. One of Champlain College's Cyber Security Faculty got a bachelor's degree in arts from this Ohioan university. Who was the other faculty member who studied there? (FirstName LastName - two words)
8. In 2019 UVM’s Ichthyology Class Had to Name their fish for class. Can you find out what the last person on the public roster named their fish?
9. Can You Figure Out Which State This Picture Has Been Taken From? See attached photo

## Answers + Methodology

### Answer 1

> namecheap

Find the whois information

### Answer 2

> timewarnercable

Google the number and find registrar information

### Answer 3

> 539544323

Leaked by Boris Johnson on twitter post: https://pbs.twimg.com/media/EUcUBu6XgAcHo93?format=jpg&name=4096x4096

### Answer 4

> 82.5%

Find on ucann-network archive.org for query `champlain college`

### Answer 5

> c96ee03c4043c366c6f573bb1d194dec8f4c0c81150c60d310bc59d9e17a6906

Get the excel sheet using the following google dork:

```
champain college Campus Locations filetype:xls
```

Submit file to VT or use cmd for getting SHA256 hash

### Answer 6

> f4952b314eb15acf0eec79c954f83881c17d50d2b5922ee37e8fc5e5cd1aeac2

Goto waybackmachine and get the exact date for `champlain.edu`. Navigate to the commons project section and grab the image. Get SHA256sum

### Answer 7

> Todd Schroeder

- Only use Google for this because other engines are unreliable for this

Google dork: `champlain college cybersecurity faculty`. From the website, we get one of the staff got bachelor degree from university of toledo (which is in Ohio). After that we search for another google dork: `inurl:champlain.edu/academics/our-faculty intext:University of Toledo` and get this name in the results

### Answer 8

> Saccopharyngiformes

Google for: `2019 UVM Ichthyology Class fish name` and enter ugly looking webpage. Grab excel sheet of student fish names, get to the last student and that's the answer.

### Answer 9

> virginia

Search image on Bing and we get a similar image: https://s3-media0.fl.yelpcdn.com/bphoto/xZ7YddL0heZk8qYvwemtyA/348s.jpg from Dinasaur Land in Virginia.
