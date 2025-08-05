//############################## ALL BASE URLS ###############################//

const brandUrl = 'https://www.minsellprice.com/api';
const growthMatridUrl = 'https://growth.matridtech.net/api';

//#################### FOR CASES IN ALL API METHODS ##########################//

const kTimeOut = 'The connection has timed out!\nPlease try again later';
const kErrorString = 'Something went wrong!\nPlease try again later';
const kErException = 'An error occurred while loading!\nPlease try again later';
const kNotValidJson = 'Error: Not Valid JSON!\nPlease try again later';
const kXMLError = 'XMLHttpRequest error.';
const kUnauthorized = 'Authentication required';
const kValidJSON200 = '200 OK Response in Valid JSON Format.';
const kEmptyResponse200Case = 'Empty Response in Status Code 200 Success Case.';
const kNonJSONNonHTML200 = 'Non-JSON and Non-HTML Status Code 200 Response.';
const kValidJSON201 = '201 OK Response in Valid JSON Format.';
const kEmptyResponse201Case = 'Empty Response in Status Code 201 Success Case.';
const kNonJSONNonHTML201 = 'Non-JSON and Non-HTML Status Code 201 Response.';
const kErrorKeyPresent = 'Error Key Present';
const kMessageKeyPresent = 'Message Key Present';

//#################### FOR KEYS IN ALL API METHODS ###########################//

const kErrorKey1 = 'error';
const kErrorKey2 = 'Error';
const kMessageKey1 = 'message';
const kMessageKey2 = 'Message';
const kAccessTokenKey = 'access_token';
const kDKey = 'data';
const kUpdateKey = 'Updated';

//#################### TOTAL CASES IN ALL API METHODS ########################//

/// [kErrorCase1]
const kCase01 = 'Case01';

/// [kSuccessCase1]
const kCase02 = 'Case02';

/// [kSuccessCase2]
const kCase03 = 'Case03';

/// [kErrorCase2]
const kCase04 = 'Case04';

/// [kErrorCase3]
const kCase05 = 'Case05';

/// [kErrorCase4]
const kCase06 = 'Case06';

/// [kSuccessCase3]
const kCase07 = 'Case07';

/// [kSuccessCase4]
const kCase08 = 'Case08';

/// [kSuccessCase5]
const kCase09 = 'Case09';

/// [kSuccessCase6]
const kCase10 = 'Case10';

/// [kErrorCase5]
const kCase11 = 'Case11';

/// [kErrorCase6]
const kCase12 = 'Case12';

/// [kErrorCase7]
const kCase13 = 'Case13';

//############## INDEXES FOR SPLITTING THE ACTUAL RESPONSE ###################//

/// START INDEX
const kSI = 0;

/// END INDEX
const kEI = 6;

/// ERROR CASE LOADING STOP TIME
const kErrorLoadStopTime = 3000;

//################# ERROR CASES LIST FOR ALL API METHODS #####################//

/// [kTimeOut]
const kErrorCase1 = kTimeOut;

/// [kErrorKeyPresent]
const kErrorCase2 = kErrorKeyPresent;

/// [kMessageKeyPresent]
const kErrorCase3 = kMessageKeyPresent;

/// [kErrorString]
const kErrorCase4 = kErrorString;

/// [kUnauthorized]
const kErrorCase5 = kUnauthorized;

/// [kNotValidJson]
const kErrorCase6 = kNotValidJson;

/// [kErException]
const kErrorCase7 = kErException;

//############### SUCCESS CASES LIST FOR ALL API METHODS #####################//

/// [kValidJSON200]
const kSuccessCase1 = kValidJSON200;

/// [kValidJSON201]
const kSuccessCase2 = kValidJSON201;

/// [kEmptyResponse200Case]
const kSuccessCase3 = kEmptyResponse200Case;

/// [kEmptyResponse201Case]
const kSuccessCase4 = kEmptyResponse201Case;

/// [kNonJSONNonHTML200]
const kSuccessCase5 = kNonJSONNonHTML200;

/// [kNonJSONNonHTML201]
const kSuccessCase6 = kNonJSONNonHTML201;
