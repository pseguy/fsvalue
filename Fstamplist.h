/*
 * Fstamplist.h
 *
 *  Created on: 10 juin 2015
 *      Author: Pascal Séguy
 */

#ifndef FSTAMPLIST_H_
#define FSTAMPLIST_H_

#include <map>
#include "Filestamp.h"


//
// A list of files in a sub-tree
//
class Fstamplist {

public:
	typedef std::map<boost::filesystem::path, Filestamp> byname_t;
	typedef std::map<hash_t, byname_t> byhash_t;

protected:
	byname_t byname;	// files list by name
	byhash_t byhash;	// files list by hash

public:
	Fstamplist();
	virtual ~Fstamplist();

	virtual void add(const Filestamp &item);	// add a file
	virtual int remove(const boost::filesystem::path &pn);	// remove a file
	virtual int scanfs(const boost::filesystem::path &dir, bool debug = false);	// scan a subtree

	virtual byhash_t getDuplicated();	// get list of duplicated hash

};

#endif /* FSTAMPLIST_H_ */
