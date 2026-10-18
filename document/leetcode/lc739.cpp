#include <iostream>
#include <vector>
#include <stack>
using namespace std;

class Solution {
public:
    vector<int> dailyTemperatures(vector<int>& temperatures) {
        stack<int> stackIndex;
        vector<int> res(temperatures.size());
        for (int i = 0; i < temperatures.size(); ++i) {
            while(!stackIndex.empty() && temperatures[i] > stackIndex.top()) {
                res[stackIndex.top()] = i - stakcIndex.top();
                stackIndex.pop();
            }
            // stackIndex空了，或者没有大的，就进栈
            if (stackIndex.empty()) {
                stackIndex.push(i);
                continue;
            }
        }

        while(!stackIndex.empty()) {
            res[stackIndex.top()] = 0;
            stackIndex.pop();
        }
        return res;
    }
};