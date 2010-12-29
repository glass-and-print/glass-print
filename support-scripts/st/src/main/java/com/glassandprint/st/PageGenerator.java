package com.glassandprint.st;

import java.io.File;
import java.io.FileFilter;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.LineNumberReader;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.antlr.stringtemplate.StringTemplate;
import org.antlr.stringtemplate.StringTemplateGroup;

public class PageGenerator {

  public static void main(String[] args) throws FileNotFoundException,
                                                IOException {
    PageGenerator.generatePages(args[0], args[1]);
  }

  private final static Pattern EXPANDED_AUTHOR =
    Pattern.compile("^By\\s(.*),\\s(.*),\\s\\(.*\\)$");

  private final static Map<String,String> DIR_TO_COLLECTION = 
    new HashMap<String,String>();
  static {
    DIR_TO_COLLECTION.put("modern", "Modern");
    DIR_TO_COLLECTION.put("maitres", "Les Maitres de l'Affiche");
    DIR_TO_COLLECTION.put("contemporary", "Contemporary");
    DIR_TO_COLLECTION.put("small-format", "Buvard");
    DIR_TO_COLLECTION.put("vivo-typo", "Typographic Posters");
    DIR_TO_COLLECTION.put("travel", "Travel Posters");
  }

  public static void generatePages(String pathToSourceDirectory,
                                   String pathToTemplatesDirectory)
  throws FileNotFoundException, IOException {
    StringTemplateGroup group =
      new StringTemplateGroup("glassandprint-templates",
                              pathToTemplatesDirectory);
    StringTemplate single = group.getInstanceOf("single");
    StringTemplate singleNextOnly = group.getInstanceOf("singlenextonly");
    StringTemplate singlePrevOnly = group.getInstanceOf("singleprevonly");
    List<File> sourceFiles = getSourceFiles(pathToSourceDirectory); 
    for (int i = 0; i < sourceFiles.size(); i++) {
      Map<String,String> attributes = getSourceAttributes(sourceFiles.get(i));
      StringTemplate template = single;
      if (i == 0) {
        template = singleNextOnly;
        attributes.put("nextfile", getFileBase(sourceFiles.get(i+1)));
      }
      else if (i == sourceFiles.size() - 1) {
        template = singlePrevOnly;
        attributes.put("prevfile", getFileBase(sourceFiles.get(i-1)));
      }
      else {
        attributes.put("nextfile", getFileBase(sourceFiles.get(i+1)));
        attributes.put("prevfile", getFileBase(sourceFiles.get(i-1)));
      }
      System.out.println(attributes);
      template.setAttributes(attributes);
      generatePage(template, pathToSourceDirectory);
      template.reset();
    }
  }

  private static List<File> getSourceFiles(String pathToSourceDirectory) {
    return Arrays.asList(
      (new File(pathToSourceDirectory)).listFiles(
        new FileFilter() {
          public boolean accept(File file) {
            return file.getAbsolutePath().endsWith(".txt");
          }
        }));
  }

  private static Map<String,String> getSourceAttributes(File sourceFile)
  throws FileNotFoundException, IOException {
    Map<String,String> attributes = new HashMap<String,String>();

    attributes.put("collection", toCollection(sourceFile));
    attributes.put("file", getFileBase(sourceFile));
    attributes.put("condition", "Condition A");

    LineNumberReader sourceReader =
      new LineNumberReader(new FileReader(sourceFile));
    String line = sourceReader.readLine();
    while (null != line) {
      lineToAttributes(line, sourceReader.getLineNumber(), attributes);
      line = sourceReader.readLine();
    }
    return attributes;
  }

  private static String toCollection(File sourceFile) {
    String parent = sourceFile.getParent();
    return DIR_TO_COLLECTION.get(parent.substring(parent.lastIndexOf("/") + 1));
  }

  private static void lineToAttributes(String line,
                                       int lineNumber,
                                       Map<String,String> attributes) {
    String trimmedLine = line.trim();
    switch (lineNumber) {
      case 1:
        attributes.put("title", trimmedLine);
        break;
      case 2:
        attributes.put("authorexpanded", trimmedLine);
        attributes.put("author", justName(trimmedLine));
        break;
      case 3:
        attributes.put("year", trimmedLine);
        break;
      case 4:
        attributes.put("size", trimmedLine);
        break;
      case 5:
        attributes.put("price", trimmedLine);
        break;
      case 6:
        attributes.put("description", trimmedLine);
        break;
      default:
        throw new UnsupportedOperationException();
    }
    attributes.put("metadescription", attributes.get("author") + "'s "
                                      + attributes.get("title")
                                      + ".");
  }

  private static void generatePage(StringTemplate template, 
                                   String pathToSourceDirectory)
  throws IOException {
    FileWriter writer = null;
    try {
      writer = new FileWriter(
                     new File(new File(pathToSourceDirectory),
                              (String)template.getAttribute("file") + ".html"));
      writer.write(template.toString());
    }
    finally {
      if (null != writer) {
        writer.close();
      }
    }
  }

  private static String justName(String author) {
    Matcher matcher = EXPANDED_AUTHOR.matcher(author);
    if (matcher.matches()) {
      return matcher.group(1);
    }
    else if (author.startsWith("By ")) {
      return author.substring(3);
    }
    return author;
  }

  private static String getFileBase(File sourceFile) {
    String fileName = sourceFile.getName();
    return fileName.substring(0, fileName.lastIndexOf(".txt"));
  }

}
