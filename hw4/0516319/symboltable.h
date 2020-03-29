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
int array_size=0;
int dim_size=0;
int flag=0;
int loop=0;
int ifreturn=0;


vector<string> func_type;
vector<struct SymbolTable> program;
vector<struct Type> type_list;
vector<struct Type> para_list;

vector<struct Type> return_list;

struct SymbolTable
{
	vector <struct Entry> entry;
};

struct Type
{
	string name,var_name;
	vector <string> dimention;

};
struct Type Return;
struct Entry
{
	string name;
	string kind;
	struct Type type;   //type
	vector <struct Type> attribute; 
	bool array=0;
	bool defi=0;
};

void Create_SymbolTable()
{
	vector <Entry> entry;
	struct SymbolTable tmp;
	tmp.entry = entry;
	program.push_back(tmp);
	global_level++;
}

void SetEntry(string name, string kind, string type_name, vector<struct Type> type_list)
{
	int entry_len = program.back().entry.size();
	program.back().entry[entry_len-1].name = name;
	program.back().entry[entry_len-1].kind = kind;
	program.back().entry[entry_len-1].type.name = type_name;
	program.back().entry[entry_len-1].attribute = type_list;
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
	tmp.defi=0;
	program.back().entry.push_back(tmp);	
}

void Create_FuncSymbolTable()
{
	Create_SymbolTable();
	int para_len = para_list.size();
	for(int i=0;i<para_len;i++)
	{
		if(para_list[i].dimention.size() == 0)Create_Entry(0);
		else Create_Entry(1);
		program.back().entry[program.back().entry.size()-1].type = para_list.front();
		program.back().entry[program.back().entry.size()-1].name = para_list.front().var_name;
		program.back().entry[program.back().entry.size()-1].kind = "parameter";
		para_list.erase(para_list.begin());
	} 
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

bool CheckExistVarName(string id)
{
	int entry_len = program.back().entry.size();
	for(int i=0;i<entry_len;i++)
	{
		if(id == program.back().entry[i].name)
		{
			printf("##########Error at Line #%2d: ",linenum);
			cout<<id<<" redeclare.##########"<<endl;
			flag=1;
			return 1;
		} 
	}
	return 0;
}

bool CheckFuncDecl(string id, string type)
{
	int entry_len = program.back().entry.size();
	for(int i=0;i<entry_len;i++)
	{
		if(id == program.back().entry[i].name)
		{
			if(type == program.back().entry[i].type.name)
			{
				int att_len = program.back().entry[i].attribute.size();
				int type_len = type_list.size();
				if(type_len == att_len)
				{
					for(int j=0;j<att_len;j++)
					{
						if(type_list[j].name != program.back().entry[i].attribute[j].name)
						{
							printf("##########Error at Line #%2d: parameter unmatch.##########\n", linenum);
							flag=1;
							return 1;
						}
						int att_dim_len = program.back().entry[i].attribute[j].dimention.size();
						int type_dim_len = type_list[j].dimention.size();
						if(att_dim_len == type_dim_len)
						{
							for(int k=0;k<att_dim_len;k++)
							{
								if(type_list[j].dimention[k] != program.back().entry[i].attribute[j].dimention[k])
								{
									printf("##########Error at Line #%2d: parameter unmatch.##########\n", linenum);
									flag=1;
									return 1;
								}
							}
						}
						else
						{
							printf("##########Error at Line #%2d: parameter unmatch.##########\n", linenum);
							flag=1;
							return 1;
						}
					}
				}
				else 
				{
					printf("##########Error at Line #%2d: parameter unmatch.##########\n", linenum);
					flag=1;
					return 1;
				}
			}
			else 
			{
				printf("##########Error at Line #%2d: function type unmatch.##########\n", linenum);	
				flag=1;
				return 1;
			}
		return 1;
		}
	}
	return 0;
}

bool HasDefi(string id)
{
	int entry_len = program.front().entry.size();
	for(int i=0;i<entry_len;i++)
	{
		if(program.front().entry[i].name == id)
		{
			if(program.front().entry[i].defi == 0)
			{
				program.front().entry[i].defi = 1;
				return 0;
			}
			else
			{
				printf("##########Error at Line #%2d: function redefined.##########\n", linenum);	
				flag=1;
				return 1;
			}
		}
		
	}

}

bool FuncExist(string id)
{
	int entry_len =  program.back().entry.size();
	for(int i=0;i<entry_len;i++)
	{
		if(id == program.back().entry[i].name)
		{
			printf("##########Error at Line #%2d: function already exists.##########\n", linenum);	
			flag=1;
			return 1;
		}
		else return 0;
	}
}

bool CheckExistVarNameInList(string id)
{
	int type_len = type_list.size();
	for(int i=0;i<type_len;i++) 
	{      
    	if(id == type_list[i].var_name)
    	{
    		printf("##########Error at Line #%2d: ",linenum);
			cout<<id<<" redeclare.##########"<<endl;
			flag=1;
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
			flag=1;
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
	program.pop_back();
    global_level--;
}

void Create_Type_Var_Name(string var_name)
{
	struct Type type;
	type.var_name = var_name;
	type_list.push_back(type);
}

bool  FuncInvoke(string  id)
{
	int entry_len = program.front().entry.size();
	for(int i=0;i<entry_len;i++)
	{
		if(id == program.front().entry[i].name)
			return 1;
	}
	printf("##########Error at Line #%2d: function ", linenum);
	cout<<id<<" didn't declare or define.##########"<<endl;
	flag=1;
	return 0;
}

bool CheckArrayInitialize()
{
	int dim_len = type_list.back().dimention.size();
	int dim=1,size = array_size;
	array_size = 0;
	for(int  i=0;i<dim_len;i++)
	{
		
		dim *= atoi(type_list.back().dimention[i].c_str());
	}
	if(dim<=0)
	{
		printf("##########Error at Line #%2d: array size must greater than 0.##########\n", linenum);
		flag=1;
		return 0;
	}
	else if(size>dim)
	{
		printf("##########Error at Line #%2d: initializers larger than array size.##########\n", linenum);
		flag=1;
		return 0;
	}
	else return 1;
}

void ArithmeticTypeCoercion()
{
	if(return_list[return_list.size()-2].name == "int" && return_list.back().name == "int")
	{
		return_list.pop_back();
	}
	else if(return_list[return_list.size()-2].name == "float" && return_list.back().name == "float")
	{
		return_list.pop_back();
	}
	else if(return_list[return_list.size()-2].name == "double" && return_list.back().name == "double")
	{
		return_list.pop_back();
	}
	else if((return_list[return_list.size()-2].name == "int" && return_list.back().name == "float") ||
		(return_list[return_list.size()-2].name == "float" && return_list.back().name == "int"))
	{
		return_list.pop_back();
		return_list.back().name = "float";
	}
	else if((return_list[return_list.size()-2].name == "int" && return_list.back().name == "double") || 
		(return_list[return_list.size()-2].name == "double" && return_list.back().name == "int"))
	{
		return_list.pop_back();
		return_list.back().name = "double";
	}
	else if((return_list[return_list.size()-2].name == "float" && return_list.back().name == "double") || 
		return_list[return_list.size()-2].name == "double" && return_list.back().name == "float")
	{
		return_list.pop_back();
		return_list.back().name = "double";
	}
	else
	{
		printf("##########Error at Line #%2d: cannot do type coercion.##########\n", linenum);
		flag=1;
		return_list.pop_back();
	}
}

bool FuncType(string id)
{
	int entry_len = program.front().entry.size();
	for(int i=0;i<entry_len;i++)
	{
		if(program.front().entry[i].name == id)
		{
			Return.name = program.front().entry[i].type.name;
			return_list.push_back(Return);
			return 1;
		}
	}
	printf("##########Error at Line #%2d: function not exist.##########\n", linenum);
	flag=1;
	return 0;
}

void SubType()
{
	if(return_list.back().name == "string" || 
		return_list.back().name == "bool")
	{
		printf("##########Error at Line #%2d: bool or string cannot do SUB_OP.##########\n", linenum);
		flag=1;
	}
}

bool CheckArrayType(string id)
{
	int size = dim_size;
	dim_size = 0;
	int program_len = program.size();
	for(int i=program_len-1;i>=0;i--)
	{
		int entry_len = program[i].entry.size();
		for(int j=0;j<entry_len;j++)
		{
			if(program[i].entry[j].name == id && size == program[i].entry[j].type.dimention.size())
			{
				Return.name = program[i].entry[j].type.name;
				return_list.push_back(Return);
				return 1;
			}
		}
	}
	Return.name = "wrong";
	return_list.push_back(Return);
	printf("##########Error at Line #%2d: no such array or wrong dimention.##########\n", linenum);
	flag=1;
	return 0;
}

bool CheckVariableType(string id)
{
	int program_len = program.size();
	for(int i=program_len-1;i>=0;i--)
	{
		int entry_len = program[i].entry.size();
		for(int j=0;j<entry_len;j++)
		{
			if(program[i].entry[j].name == id && program[i].entry[j].array == 0)
			{
				Return.name = program[i].entry[j].type.name;
				return_list.push_back(Return);
				return 1;
			}
		}
	}
	Return.name = "wrong";
	return_list.push_back(Return);
	printf("##########Error at Line #%2d: no such variable or it's an array.##########\n", linenum);
	flag=1;	
	return 0;
}

void RelationTypeCoercion()
{
	if((return_list[return_list.size()-2].name == "bool" ||
		return_list[return_list.size()-2].name == "string") || (
		return_list.back().name == "bool" ||
		return_list.back().name == "string"))
	{
		printf("##########Error at Line #%2d: wrong type to do relational_op.##########\n", linenum);
		flag=1;
	}	
	return_list.pop_back();
	return_list.back().name = "bool";
	
}

void LogicalTypeCoercion()
{
	if(return_list[return_list.size()-2].name != "bool" ||
		return_list.back().name != "bool")
	{
		printf("##########Error at Line #%2d: wrong type to do logical_op.##########\n", linenum);
		flag=1;
		return_list.pop_back();
		return_list.back().name = "bool";
	}
	else
	{
		return_list.pop_back();
	}
}

void SimpleStatementTypeCoercion()
{
	if(return_list[return_list.size()-2].name == "float" && return_list.back().name == "int"){}
	else if(return_list[return_list.size()-2].name == "double" && return_list.back().name == "float"){}
	else if(return_list[return_list.size()-2].name == "double" && return_list.back().name == "int"){}
	else if(return_list[return_list.size()-2].name == return_list.back().name){}
	else
	{
		printf("##########Error at Line #%2d: assign_op type coercion error.##########\n", linenum);
		flag=1;
	}
	return_list.clear();
}

void CheckControlExpression()
{
	if(return_list.back().name != "bool")
	{
		printf("##########Error at Line #%2d: control expression isn't bool type.##########\n", linenum);
		flag=1;
	}
	return_list.clear();
	
}

void CheckVarDeclType(string type)
{
	int list_len = return_list.size();
	for(int i=0;i<list_len;i++)
	{
		if(return_list[i].name != type)
		{
			printf("##########Error at Line #%2d: value didn't match scalar type.##########\n", linenum);
			flag=1;
			break;		
		}
	}
	return_list.clear();
}

void CheckModOp()
{
	if(return_list[return_list.size()-2].name != "int" || return_list.back().name != "int")
	{
		printf("##########Error at Line #%2d: only int can do mod_op.##########\n", linenum);
		flag=1;
	}
	return_list.pop_back();
	return_list.back().name = "int";
}

void CheckReturnType()
{
	if(func_type.back() == "float" && return_list.back().name == "int"){}
	else if(func_type.back() == "double" && return_list.back().name == "int"){}
	else if(func_type.back() == "double" && return_list.back().name == "float"){}
	else if(func_type.back() == return_list.back().name){}
	else if(func_type.back() == "void")
	{
		printf("##########Error at Line #%2d: void type function has no return statement.##########\n", linenum);
		flag=1;
	}
	else
	{
		printf("##########Error at Line #%2d: return type unmatch.##########\n", linenum);
		flag=1;		
	}
	return_list.clear();
}

void BoolExpression()
{
	if(return_list.back().name != "bool")
	{
		printf("##########Error at Line #%2d: should be bool type.##########\n", linenum);
		flag=1;
	}
	return_list.clear();
}
