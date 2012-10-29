#== arg0: path to the model files
#== arg1: path to the templates directory
#== arg2: path to the output directory
#== arg3: (any value) causes the target files to get overwritten
java -classpath target/classes:lib/antlr-2.7.7.jar:lib/stringtemplate-3.2.1.jar com.glassandprint.st.PageGenerator "$@"
