public class Fon_TotalNumberOfMembershipSchedule implements Schedulable{
    
    public static final String CRON_EXPR = '0 0 0 1 * ? *';
    
    public static String scheduleIt() {
        Fon_TotalNumberOfMembershipSchedule job = new Fon_TotalNumberOfMembershipSchedule();
        return System.schedule('Something Descriptive', CRON_EXPR, job);
    }
    public void execute(SchedulableContext sc){
        Fon_TotalNumberOfMembershipBatch btch = new Fon_TotalNumberOfMembershipBatch();
        Database.executeBatch(btch,1);
    }
}