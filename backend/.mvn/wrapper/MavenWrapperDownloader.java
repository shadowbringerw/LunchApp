/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   https://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URL;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.util.Properties;

public class MavenWrapperDownloader {

  private static final String WRAPPER_PROPERTIES_PATH = ".mvn/wrapper/maven-wrapper.properties";
  private static final String WRAPPER_JAR_PATH = ".mvn/wrapper/maven-wrapper.jar";
  private static final String PROPERTY_NAME_WRAPPER_URL = "wrapperUrl";

  public static void main(String[] args) {
    System.out.println("- Downloader started");
    final File baseDirectory = new File(System.getProperty("maven.multiModuleProjectDirectory", "."));
    System.out.println("- Using base directory: " + baseDirectory.getAbsolutePath());

    final File propertiesFile = new File(baseDirectory, WRAPPER_PROPERTIES_PATH);
    final File wrapperJarFile = new File(baseDirectory, WRAPPER_JAR_PATH);
    final String wrapperUrl = readWrapperUrl(propertiesFile);

    if (wrapperJarFile.exists()) {
      System.out.println("- Maven wrapper jar already exists: " + wrapperJarFile.getAbsolutePath());
      return;
    }

    System.out.println("- Downloading from: " + wrapperUrl);
    try {
      downloadFileFromURL(wrapperUrl, wrapperJarFile);
      System.out.println("Done");
    } catch (IOException e) {
      System.out.println("- Error downloading Maven wrapper jar");
      e.printStackTrace();
      System.exit(1);
    }
  }

  private static String readWrapperUrl(File propertiesFile) {
    if (!propertiesFile.exists()) {
      return "https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar";
    }
    try (FileInputStream fis = new FileInputStream(propertiesFile)) {
      final Properties props = new Properties();
      props.load(fis);
      final String url = props.getProperty(PROPERTY_NAME_WRAPPER_URL);
      if (url != null && !url.isBlank()) {
        return url.trim();
      }
    } catch (IOException ignored) {
      // fall through
    }
    return "https://repo.maven.apache.org/maven2/org/apache/maven/wrapper/maven-wrapper/3.3.2/maven-wrapper-3.3.2.jar";
  }

  private static void downloadFileFromURL(String urlString, File destination) throws IOException {
    destination.getParentFile().mkdirs();
    final URL website = new URL(urlString);
    try (ReadableByteChannel rbc = Channels.newChannel(website.openStream());
        FileOutputStream fos = new FileOutputStream(destination)) {
      fos.getChannel().transferFrom(rbc, 0, Long.MAX_VALUE);
    }
  }
}

