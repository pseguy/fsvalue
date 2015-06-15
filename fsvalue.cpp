/*
 * fsvalue: A simple tool to restore hard-link files in a sub-tree.
 *
 * Copyright 2015 Pascal Séguy	<pascal.seguy@laposte.net>
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <iostream>
#include <string>
#include <sstream>
#include <iomanip>
#include <deque>
#include <algorithm>
#include <cassert>
#include <boost/algorithm/string.hpp>

#include "Fstamplist.h"

using namespace std;

bool verbose = false;
bool debug = false;
bool dryrun = true;
bool interactive = false;


void usage()
{
	cerr
		<< "fsvalue [opt] [dir]\n"
			" -d\t: debug\n"
			" -e\t: Execute, no dry-run\n"
			" -i\t: Interactive. Require user's approbation before each action\n"
			" -m nk\t: File size limit in KiB\n"
			" -v\t: Verbose\n"
		<< endl;

	exit(1);
}


int main(int argc, const char *argv[])
{
int carg = 1;
string fs1n = ".";
Fstamplist fs;
size_t slimit = 0;

	while(carg < argc && argv[carg][0] == '-') {
		switch(argv[carg][1]) {
			case 'd':
				debug = true;
			break;
			case 'i':
				interactive = true;
			break;
			case 'm':
				if(argv[carg][2]) {
					istringstream is(&argv[carg][2]);
					is >> slimit;
				}else if(carg + 1 < argc && argv[carg + 1][0] != '-') {
					++carg;
					istringstream is(argv[carg]);
					is >> slimit;
				}else{
					usage();
				}
				if(!slimit) usage();
			break;
			case 'v':
				verbose = true;
			break;
			case 'e':
				dryrun = false;
			break;
			default: usage();
		}
		++carg;
	}

	if(carg < argc) {
		fs1n = argv[carg++];
	}

	if(slimit > 0) Filestamp::slimit = slimit;

	fs.scanfs(fs1n, debug);

	{ Fstamplist::byhash_t list;

		list = fs.getDuplicated();

		for(auto &hash:list) {
			typedef deque<Filestamp> fslist_t;
			fslist_t tmpl;

			//
			// Convert the map to deque
			//
			for(auto &node:hash.second) {
				tmpl.push_back(node.second);
			}

			//
			// sort it by link
			//
			sort(tmpl.begin(), tmpl.end(),
				[] (const Filestamp &a, const Filestamp &b) -> bool
				{
					return a.hard_link_count() > b.hard_link_count();
				}
			);

			//
			// display
			//
			if(verbose) {
				cout << '\n';
				for(auto &node:tmpl) {
					const Filestamp &file(node);
					cout
						<< setw(4)
						<< file.hard_link_count()
						<< "  "
						<< file
						<< endl;
				}
			}

			//
			// try to hard-link
			//
			{ Filestamp prevfile;
				int cnt = 0;
				const int nfiles = tmpl.size();

				//
				// For each identical files
				//
				for(auto &node:tmpl) {
					const Filestamp &file(node);

					if(cnt > 0) {	// If not the first file

						if(file.hard_link_count() < 2) {	// if not linked
							if(dryrun) {
								cout
									<< "ln -f "
									<< prevfile.bash_str()
									<< "\t"
									<< file.bash_str()
									<< endl;
							}else{
								string fn = file.path().string();
								string tmpf = fn + ".tmp";
								bool doit = true;

								if(interactive) {
									bool gotanswer = false;
									do {
										cerr
											<< "Link "
											<< prevfile
											<< " to "
											<< file
											<< " ? (Y/n) "
											<< flush;
										string ui;
										cin >> ui;
										boost::algorithm::to_lower(ui);

										if(ui.empty() || ui == "y") {
											gotanswer = true;
										}else if(ui == "n") {
											gotanswer = true;
											doit = false;
										}
									}while(!gotanswer);
								}

								if(doit) {
									//
									// hide the target
									//
									if(::rename(fn.c_str(), tmpf.c_str()) < 0) {
										cerr
											<< "rename "
											<< file
											<< " to "
											<< tmpf
											<< "failed: "
											<< strerror(errno)
											<< endl;
										exit(1);
									}

									//
									// perform the hardlink
									//
									if(::link(prevfile.path().c_str(), file.path().c_str()) < 0) {
										cerr
											<< "link from "
											<< prevfile
											<< " to "
											<< file
											<< " failed: "
											<< strerror(errno)
											<< endl;

										//
										// Restore the original
										//
										if(::rename(tmpf.c_str(), fn.c_str()) < 0) {
											cerr
												<< "couldn't get bak "
												<< file
												<< " from "
												<< tmpf
												<< ": "
												<< strerror(errno)
												<< endl;
										}
										exit(1);
									}

									//
									// remove the original file
									//
									::unlink(tmpf.c_str());

									cerr
										<< prevfile
										<< "  linked to  "
										<< file
										<< endl;
								}else{
									cerr << " Skipped" << endl;
								}
							}
						}else{
							if(nfiles != file.hard_link_count()) {
								cerr
									<< "Notice: "
									<< prevfile
									<< " couldn't be hard-linked to "
									<< file
									<< " because the target is already hard-linked"
									<< endl;
								break;	// it's useless to continue
							}
						}
					}
					prevfile = file;
					++cnt;
				}
			}
		}
	}

	return(0);
}
