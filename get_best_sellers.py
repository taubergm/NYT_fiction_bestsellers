import pprint
import requests
import csv
import datetime

def parse_books(book_list, date):
    '''
    Based on: function parse_articles from 
    This function takes in a response to the NYT books api and parses
    the books into a list of dictionaries
    '''
    books = []
    for i in book_list['results']['books']:
        dic = {}
        dic['age_group'] = i['age_group']
        #if i['amazon_product_url'] is not None:
        #    dic['amazon_product_url'] = i['amazon_product_url'].encode("utf8")
        #dic['asterisk'] = i['asterisk']
        dic['author'] = i['author'].encode("utf8")        
        #dic['book_image'] = i['book_image'].encode("utf8")
        #dic['book_image_height'] = i['book_image_height']
        #dic['book_image_width'] = i['book_image_width']
        dic['book_review_link'] = i['book_review_link'].encode("utf8")
        dic['contributor'] = i['contributor'].encode("utf8")
        #dic['contributor_note'] = i['contributor_note'].encode("utf8")
        dic['dagger'] = i['dagger']
        dic['first_chapter_link'] = i['first_chapter_link'].encode("utf8")
        dic['price'] = i['price']
        dic['primary_isbn10'] = i['primary_isbn10'].encode("utf8")
        dic['primary_isbn13'] = i['primary_isbn13'].encode("utf8")
        dic['publisher'] = i['publisher'].encode("utf8")
        dic['sunday_review_link'] = i['sunday_review_link'].encode("utf8")
        dic['title'] = i['title'].encode("utf8")
        dic['weeks_on_list'] = i['weeks_on_list']
        # add a date so that we know when it was a best-seller
        dic['date'] = date
        books.append(dic)
    return(books) 

#eg: https://api.nytimes.com/svc/books/v3/lists/2017-03-13/Combined%20Print%20and%20E-Book%20Fiction.json?api_key=13d664889d584dbab46fcf8baa54ef20
BOOKS_ROOT = "https://api.nytimes.com/svc/books/v3/lists"
LIST = "Combined%20Print%20and%20E-Book%20Fiction.json"   #you can change to other lists available at https://developer.nytimes.com

# Add your API key here 
API_KEY = ""


bestsellers = []
num_days_to_get = 365 # you can use up to 1000 api calls a day so max=1000

for i in range(0,num_days_to_get):
    day = datetime.datetime.now() - datetime.timedelta(days=i)  
    date = str(day.date())
    print date
    url = "%s/%s/%s?api_key=%s" % (BOOKS_ROOT, date, LIST, API_KEY)
    url = url.strip()  
    print url
    r = requests.get(url)
    if (r.status_code == 200):
        results = r.json()
        books = parse_books(results, date)
        bestsellers.extend(books)

    if (bestsellers[0].keys() is not None):
        keys = bestsellers[0].keys()
        # Print all results to a csv file
        with open('bestsellers.csv', 'wb') as output_file:
            dict_writer = csv.DictWriter(output_file, keys)
            dict_writer.writeheader()
            dict_writer.writerows(bestsellers)

