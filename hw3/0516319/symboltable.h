#include <string.h>
#include <stdlib.h>
#include <iostream>
#include <stack>
#include <queue>
#include <vector>
#include <list>
#include <string>

using namespace std;
extern int Opt_Symbol;
extern int linenum; 
int global_level=-1;

stack<struct SymbolTable> program;
vector<struct Type> type_list;
vector<struct Type> para_list;

struct SymbolTable
{
	int capacity;
	int now_level;
	int now_size;
	vector <struct Entry> entry;
};

struct Type
{
	string name,var_name,scalar;
	vector <string> dimention;
};

struct Entry
{
	string name;
	string kind;
	struct Type type;   //type
	vector <struct Type> attribute; //
	bool array=0;
};

void Create_SymbolTable()
{
	vector <Entry> entry;
	struct SymbolTable tmp;
	tmp.entry = entry;
	program.push(tmp);
	global_level++;
}

void Create_Entry(bool array)
{
	struct Type type;
	vector <struct Type> att;
	struct Entry tmp;
	tmp.name = "";
	tmp.kind = "";
	tmp.type = type;
	tmp.attribute = att;
	tmp.array = array;
	program.top().entry.push_back(tmp);	
}

void Print_Entry(struct Entry tmp)
{
	int i, j, type_len, att_len, att_ty_len;

    cout.setf(ios::left);
    cout.width(33);
	cout << tmp.name;
	cout.width(11);
	cout << tmp.kind;
	
	cout <<global_level;
	cout.width(11);
	if(global_level != 0)cout<<"(local)";
	else cout<<"(global)";

	type_len = tmp.type.dimention.size();
	string concat1 = tmp.type.name;
	string brace1 = "[";
	string brace2 = "]";

	for(i=0;i<type_len;i++)
	{
		concat1 += brace1;
		concat1 += tmp.type.dimention[i] ;
		concat1 += brace2;
	}
	cout.width(19);
	cout <<concat1;

    string concat2="";
	att_len = tmp.attribute.size();
	for(i=0;i<att_len;i++)
	{
	    concat2 += tmp.attribute[i].name;
		att_ty_len = tmp.attribute[i].dimention.size();
		for(j=0;j<att_ty_len;j++)
		{
		    concat2 += brace1;
			concat2 += tmp.attribute[i].dimention[j];
			concat2 += brace2;
		}
        if(i!=att_len-1)concat2 +=",";
	}
	cout.width(24);
    cout <<concat2;
	cout <<endl;

}

bool CheckExist(string id)
{
	int entry_len = program.top().entry.size();
	for(int i=0;i<entry_len;i++)
	{
		if(id == program.top().entry[i].name)
		{
			printf("##########Error at Line #%2d: ",linenum);
			cout<<id<<" redeclare.##########"<<endl;
			return 1;
		} 
	}
	return 0;
}

bool CheckExistFunc(string id)
{
	int entry_len = program.top().entry.size();
	for(int i=0;i<entry_len;i++)
	{
		if(id == program.top().entry[i].name)
		{
			return 1;
		} 
	}
	return 0;
}

bool CheckExistVarName(string id)
{
	int type_len = type_list.size();
	for(int i=0;i<type_len;i++) 
	{      
    	if(id == type_list[i].var_name)
    	{
    		printf("##########Error at Line #%2d: ",linenum);
			cout<<id<<" redeclare.##########"<<endl;
			return 1;
    	}
	}
	return 0;
}

bool CheckExistArrayName(string id)
{
	int type_len = type_list.size();
	for(int i=0;i<type_len-1;i++) 
	{      
    	if(id == type_list[i].var_name)
    	{
    		printf("##########Error at Line #%2d: ",linenum);
			cout<<id<<" redeclare.##########"<<endl;
			return 1;
    	}
	}
	return 0;
}


void Print_SymbolTable(struct SymbolTable tmp)
{
	if(!Opt_Symbol)return;
    printf("=======================================================================================\n");
    printf("Name                             Kind       Level       Type               Attribute               \n");
    printf("---------------------------------------------------------------------------------------\n");
	int i, j, k, table_num, now_num = 0;
	int len;
	len = tmp.entry.size();
	for(i=0;i<len;i++)
	{
		Print_Entry(tmp.entry[i]);
	}
	printf("=======================================================================================\n");
	program.pop();
    global_level--;
    //cout<<"type_list = "<<type_list.size()<<endl;
    //cout<<"para_list = "<<para_list.size()<<endl;
}

void Create_Type_Var_Name(string var_name)
{
	struct Type type;
	type.var_name = var_name;
	type_list.push_back(type);
}
