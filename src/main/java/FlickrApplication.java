import com.flickr4java.flickr.Flickr;
import com.flickr4java.flickr.FlickrException;
import com.flickr4java.flickr.REST;

import com.flickr4java.flickr.photos.Photo;
import com.flickr4java.flickr.photos.SearchParameters;
import sun.util.calendar.BaseCalendar;


import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.*;

public class FlickrApplication {

    public static void main(String[] args) throws FlickrException, FileNotFoundException {


        String apiKey = args[0];
        String sharedSecret = args[1];
        Flickr f = new Flickr(apiKey, sharedSecret, new REST());


        //bounding box Munich City
        String up = "48.2485";
        String down = "48.0104";
        String left = "11.2970";
        String right = "11.8361";

        //initialize printer


        //repeat from 1 06 until last day of 08
        Calendar cal = Calendar.getInstance();

        int year = 2017;
        int fileIndex = 500;
        //for (int month = 6; month <= cal.getMaximum(Calendar.MONTH); month++) {
        for (int month = 6; month <= 7 ; month++) {
            for (int day = 0; day <= cal.getMaximum(Calendar.DAY_OF_MONTH); day++) {

                PrintWriter pw = new PrintWriter(new File(fileIndex + ".csv"));

                String header = "year,month,day,id,personId,location,lon,lat,time";
                pw.println(header);

                cal.set(2017, month, day, 0, 0, 0);
                Date startDate = cal.getTime();
                cal.set(2017, month, day, cal.getMaximum(Calendar.HOUR_OF_DAY), cal.getMaximum(Calendar.MINUTE), cal.getMaximum(Calendar.SECOND));
                Date endTime = cal.getTime();

                SearchParameters searchParameters = new SearchParameters();
                searchParameters.setBBox(left, down, right, up);
                searchParameters.setHasGeo(true);
                searchParameters.setMinTakenDate(startDate);
                searchParameters.setMaxTakenDate(endTime);

                boolean still = true;
                int counter = 0;
                int page = 1;
                ArrayList<Photo> searchResults = new ArrayList<>();
                while (still) {

                   try {
                       ArrayList<Photo> searchResultsPage = f.getPhotosInterface().search(searchParameters, 250, page);
                       if (searchResultsPage.size() > 0) {
                           counter += searchResultsPage.size();
                           page++;
                           searchResults.addAll(searchResultsPage);
                           System.out.println("Collected " + counter + " images.");
                       } else {
                           still = false;
                       }
                   } catch (Exception e){
                       still = false;
                   }
                }
                System.out.println(counter + " pictures on " + startDate.toString());
                counter =0;
                for (Photo photo : searchResults){
                    try {
                        Photo picture = f.getPhotosInterface().getPhoto(photo.getId());
                        pw.print(year);
                        pw.print(",");
                        pw.print(month);
                        pw.print(",");
                        pw.print(day);
                        pw.print(",");
                        pw.print(picture.getId());
                        pw.print(",");
                        pw.print(picture.getOwner().getId());
                        pw.print(",");
                        pw.print(picture.getOwner().getLocation().replace(",", "-"));
                        pw.print(",");
                        pw.print(picture.getGeoData().getLongitude());
                        pw.print(",");
                        pw.print(picture.getGeoData().getLatitude());
                        pw.print(",");
                        pw.print(picture.getDateTaken().getTime());
                        pw.println();
                        counter++;
                        System.out.println("Found a picture with information. Sum " + counter);
                    } catch (Exception e){
                        //do nothing
                        System.out.println("Found a picture with no information");
                    }
                }
                System.out.println("A total of " + counter + " pictures were processed");
                pw.flush();
                pw.close();
                fileIndex++;
            }
        }
    }
}


