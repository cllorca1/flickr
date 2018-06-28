import com.flickr4java.flickr.Flickr;
import com.flickr4java.flickr.FlickrException;
import com.flickr4java.flickr.REST;
import com.flickr4java.flickr.photos.Photo;
import com.flickr4java.flickr.photos.SearchParameters;

import java.io.*;
import java.lang.reflect.Array;
import java.util.*;

public class FlickrByUserSearch {



    public static void main(String[] args) throws FlickrException, IOException {

        Map<String, Map<String, PictureRecord>> usersAndPictures = new HashMap<>();

        String apiKey = args[0];
        String sharedSecret = args[1];
        Flickr f = new Flickr(apiKey, sharedSecret, new REST());

        //bounding box Surroundings
        String up = "49.1116";
        String down = "47.2084";
        String left = "9.8602";
        String right = "14.1724";


        BufferedReader br = new BufferedReader(new FileReader("example.csv"));
        int positionId = 3;
        int positionPersonId = 4;
        int positionDay = 2;
        int positionMonth = 1;

        br.readLine();

        String line;
        int counter = 0;
        while((line = br.readLine())!= null){
            String[] lineElements = line.split(",");
            String userId = lineElements[positionPersonId].replace("\"", "");
            String photoId = lineElements[positionId];
            int day = Integer.parseInt(lineElements[positionDay]);
            int month = Integer.parseInt(lineElements[positionMonth]);


            if (usersAndPictures.containsKey(userId)){
                usersAndPictures.get(userId).put(photoId, new PictureRecord(photoId, day, month));
            } else {
                Map<String, PictureRecord>listOfPictures = new HashMap<>();
                listOfPictures.put(photoId, new PictureRecord(photoId, day, month));
                usersAndPictures.put(userId, listOfPictures);
            }
            counter++;
        }

        br.close();

        System.out.println(usersAndPictures.size() + " users with " + counter + " pictures.");






        Calendar cal = Calendar.getInstance();


        int userIndex = 0;

        for (String userId : usersAndPictures.keySet()){

            String thisUserFileName = "./byUSer/" + userIndex + ".csv";

            if (!(new File(thisUserFileName).exists())){
                PrintWriter pw = new PrintWriter(new File(thisUserFileName));

                String header = "index,id,personId,lon,lat,time";
                pw.println(header);


                Set<String> photoIds = usersAndPictures.get(userId).keySet();
                cal.set(2017,Calendar.DECEMBER,31,23,59);
                Date minDate = cal.getTime();
                cal.set(2017,Calendar.JANUARY,0,0,0);
                Date maxDate = cal.getTime();
                for (String photoId : photoIds){
                    PictureRecord pr = usersAndPictures.get(userId).get(photoId);
                    cal.set(2017,pr.month, pr.day, 12,0);
                    if (cal.getTime().before(minDate)){
                        minDate = cal.getTime();
                    }
                    if (cal.getTime().after(maxDate)){
                        maxDate = cal.getTime();
                    }
                }


                SearchParameters searchParameters = new SearchParameters();
                searchParameters.setBBox(left, down, right, up);
                searchParameters.setHasGeo(true);
                searchParameters.setMaxTakenDate(new Date(maxDate.getTime()+ 7*24*3600*1000));
                searchParameters.setMinTakenDate(new Date(minDate.getTime() - 7*24*3600*1000));
                searchParameters.setUserId(userId);


                boolean still = true;
                counter = 0;
                int page = 1;
                ArrayList<Photo> searchResultsPage;
                while (still) {
                    searchResultsPage = f.getPhotosInterface().search(searchParameters, 250, page);

                    if (searchResultsPage.size() > 0) {

                        for (Photo photo : searchResultsPage) {
                            if (!photoIds.contains(photo.getId())) {
                                Photo picture = f.getPhotosInterface().getPhoto(photo.getId());
                                pw.print(counter);
                                pw.print(",");
                                pw.print(picture.getId());
                                pw.print(",");
                                pw.print(userId);
                                pw.print(",");
                                pw.print(picture.getGeoData().getLongitude());
                                pw.print(",");
                                pw.print(picture.getGeoData().getLatitude());
                                pw.print(",");
                                pw.print(picture.getDateTaken().getTime());
                                pw.println();
                                counter++;
                            }


                        }

                        page++;
                    } else {
                        if (counter == 0){
                            pw.println("-1," + userId + ",-1,-1,-1,-1");
                        }
                        still = false;
                    }

                }

                System.out.println("A total of " + counter + " pictures taken by "  + userId);
                pw.close();
            }

            userIndex++;


        }



    }

    private static class PictureRecord{
        private String id;
        private int day;
        private int month;

        public PictureRecord(String id, int day, int month) {
            this.id = id;
            this.day = day;
            this.month = month;
        }
    }
}
