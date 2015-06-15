/*
 * Filestamp.cpp
 *
 *  Created on: 10 juin 2015
 *      Author: Pascal Séguy
 */

#include "Filestamp.h"
#include <fstream>
#include <sha.h>
#include <iomanip>
#include <sstream>
#include <limits>

#include "unicode/utypes.h"
#include <unicode/coll.h>
#include <unicode/unistr.h>
#include <unicode/ustring.h>
#include "unicode/ucnv.h"
#include <unicode/schriter.h>
#include "unicode/utypes.h"

using namespace std;

std::size_t Filestamp::slimit = std::numeric_limits<std::size_t>::max() ;



string printstrbin(std::string str)
{
	const char *ps = str.data();
	ostringstream cout;

	cout << hex << setw(2) << setfill('0');

	for(int cnt = str.length(); cnt > 0; --cnt) {
		cout << (int)(unsigned char)*ps++;
	}
	return(cout.str());
}


Filestamp::Filestamp()
{
}


Filestamp::Filestamp(boost::filesystem::directory_entry file)
: directory_entry(file)
{
CryptoPP::SHA1 digest;
ifstream cin;
	cin.exceptions(cin.badbit);
	cin.open(this->path().c_str());
	cin.exceptions(cin.goodbit);

	{ char buf[1024];
		for(unsigned long cnt = 0; cin && cnt < slimit; ++cnt) {
			cin.read(buf, sizeof(buf));
			digest.Update((unsigned char*)buf, cin.gcount());
		}
	}
	char buf[digest.DigestSize()];
	digest.Final((unsigned char*)buf);
	if(false) cerr << "sizeof buf=" << sizeof(buf) << endl;
	hash = std::string(buf, sizeof(buf));
	if(false)
		cerr << *this
			<< "\t"
			<< printstrbin(hash)
			<< endl;

}


Filestamp::~Filestamp()
{
	// TODO Auto-generated destructor stub
}


std::ostream &operator<<(std::ostream &cout, const Filestamp &file)
{
	cout << file.path();
	return(cout);
}



class UnicodeString mkuc(const std::string str)
{
UnicodeString us;
UErrorCode uc = U_ZERO_ERROR;
const int ucblength = str.length() + 10;
int destlen = 0;
UChar ucb[ucblength];

	u_strFromUTF8(ucb, ucblength, &destlen, str.data(), str.length(), &uc);
    if(U_FAILURE(uc)) {
		cerr << "u_strFromUTF8: " << u_errorName(uc) << " [" << str << "]" << endl;
		throw std::logic_error("mkuc");
    }
    //if(destlen > 0) --destlen;
	us.append(ucb, destlen);
	return(us);
}


std::string uc2s(const class UnicodeString &us)
{
UErrorCode uc = U_ZERO_ERROR;
const int destlength = us.length() * 2;
char *dest = new char[destlength];
int destlen;

  	u_strToUTF8(dest, destlength, &destlen, us.getBuffer(), us.length(), &uc);

	string res(dest, destlen);
	delete dest;
	return(res);
}


std::string Filestamp::bash_str() const
{
UnicodeString us(mkuc(path().string()));
UnicodeString res;
StringCharacterIterator usiter(us);

	res.append('\'');
	for(UChar ch = usiter.first();
		ch != CharacterIterator::DONE;
		ch = usiter.next()) {

		if(ch == '\'') {
			res.append("'\"'\"'");
		}else{
			res.append(ch);
		}
	}
	res.append('\'');
	return(uc2s(res));
}
