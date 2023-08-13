package com.knight;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.Properties;

public class Main {
    public static void main(String[] args) {
        Properties properties = new Properties();
        try {
            if (args.length > 0 && args[0].equals("debug")) {
                properties.load(new InputStreamReader(Main.class.getResourceAsStream("/conf.properties")));
            }
            else {
                properties.load(new FileInputStream("resources/conf.properties"));
            }
            System.out.println(properties);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
