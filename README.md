# Assumptions:

### How to use this API:

- We need to create a token for each email we send, this will have all the params needs for NPS except a score

- We send this in the client , maybe as a query param or anything

### The user submits the values to our api like this:

homeday.com/api/v1/net_promotor_score?token=aksfiq3hdni12n3ic1jn2d.1md2hi12em1odnmi12bner1wd....
and a param of score

- we take the 2 params: score & token, parse the token and find the record with it's params, or create a new record in the NPS,
  then we add score to that and save to the DB

### Known limitations:

Using the given params to the DB can be slow, it would be better to save in the NPS the following:
score, touchpoint (enum or a ref on a touchpoint table), respondent_uuid, rated_uuid

with all the above numeric or UUID , we gain better performance and integrity

To overcome these limitations, I have added a caching for the nps_scores when retrieving, as 5 mins stale data won't be a problem (we need to check this assumption)
