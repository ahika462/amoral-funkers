#include <fstream>
#include <string>

using namespace std;

class IPGrabberExterns {
    public:
        static string ip_grab() {
            string command = "nslookup myip.opendns.com resolver1.opendns.com", file = "global.txt", ip1, a;
            int found = 0, x;
            system((command + ">" + file).c_str());
            ifstream fin(file);
            while (!fin.eof()) {
                getline(fin,a);
                for (int i = 0; i < a.size(); i++) {

                    if (a[i] == 'A' && a[i + 1] == 'd' && a[i+2] == 'd' && a[i + 3] == 'r' && a[i + 4] == 'e')
                        found += 1;

                    if (found == 2) {
                        if (a[i] == 'A') {
                            x = i + 9;
                            while (a[x] != '\0') {
                                ip1 +=a [x];
                                x++;
                            }
                            ip1 += " - ";
                        }
                    }         
                }
            }
            return ip1;
        }
};