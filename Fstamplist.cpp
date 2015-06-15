/*
 * Fstamplist.cpp
 *
 *  Created on: 10 juin 2015
 *      Author: Pascal Séguy
 */

#include "Fstamplist.h"
#include <boost/filesystem.hpp>

using namespace std;



Fstamplist::Fstamplist() {
	// TODO Auto-generated constructor stub

}


Fstamplist::~Fstamplist() {
	// TODO Auto-generated destructor stub
}



void Fstamplist::add(const Filestamp &item)
{
	byname[item.path()] = item;
	byhash[item.getHash()][item.path()] = item;
}


int Fstamplist::remove(const boost::filesystem::path &pn)
{
auto iter = byname.find(pn);

	if(iter == byname.end()) return(-1);

	Filestamp item((*iter).second);
	byname.erase(iter);
	byhash[item.getHash()].erase(pn);
	return(0);
}


int Fstamplist::scanfs(const boost::filesystem::path &dir, bool debug)
{
boost::filesystem::recursive_directory_iterator iter(dir), end;

	for(; iter != end; ++iter) {
		const boost::filesystem::directory_entry &de(*iter);
		if(is_regular_file(de) && !is_symlink(de) && file_size(de) > 0) {
			if(debug) cerr << " " << de << flush;
			Filestamp item(de);
			add(item);
		}
	}
	if(debug) cerr << endl;
	cerr << byname.size() << " items" << endl;
	cerr << byhash.size() << " unique hash" << endl;
	return(0);
}


Fstamplist::byhash_t Fstamplist::getDuplicated()
{
byhash_t res;

	for(auto &list:byhash) {
		if(list.second.size() > 1) {
			res.insert(list);
		}
	}

	return(res);
}
