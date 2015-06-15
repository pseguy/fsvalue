/*
 * Filestamp.h
 *
 *  Created on: 10 juin 2015
 *      Author: Pascal Séguy
 */

#ifndef FILESTAMP_H_
#define FILESTAMP_H_

#include <boost/filesystem/operations.hpp>


typedef std::string hash_t;


//
// A file class with an additional hash of the file.
//
class Filestamp: public boost::filesystem::directory_entry
{

protected:
	hash_t	hash;	// the hash on the file

public:
	Filestamp();
	Filestamp(boost::filesystem::directory_entry file);
	virtual ~Filestamp();

	/**
	 * hash getter
	 */
	hash_t getHash() const { return(hash); }

	long hard_link_count() const { return boost::filesystem::hard_link_count(path()); }

	static std::size_t slimit;	// sile limit of file in KiB

	friend std::ostream &operator<<(std::ostream &cout, const Filestamp &file);

	/**
	 * Returns an escaped value of the file name suitable for bash
	 */
	std::string bash_str() const;
};

#endif /* FILESTAMP_H_ */
