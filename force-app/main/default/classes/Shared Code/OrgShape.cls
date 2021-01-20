/**
 * @description Class contains static methods for determining if specific
 * platform features are enabled here. For example, do we have platform cache
 * enabled. You could also write similar methods for experiences.
 */
public inherited sharing class OrgShape {
    /**
     * @description Method determines if platform cache is enabled for this org
     * Note: fail-safes to false.
     * Note: Allows override by setting OrgShape.disablePlatformCache
     * equal to true. Use this in test contexts where cache is not available like
     * when you have to use seeAllData=true
     * @return      `Boolean`
     */
    public static Boolean isPlatformCacheEnabled() {
        if (isSeeAllDataTrue()) {
            return false;
        }

        Boolean cacheAvailable = false;
        try {
            Cache.org.getCapacity();
            cacheAvailable = true;
        } catch (Exception ex) {
            system.debug('Failed to get orgCache');
        }
        return cacheAvailable;
    }

    /**
     * @description Certain features of the platform are incompatible with
     * data-siloed tests. These features require testing with the annotation
     * @test(seeAllData=true). Other platform features are incompatible with
     * seeAllData=true. When used in a test context, this method determines if
     * the currently running test is executing with, or without seeAllData=true.
     *
     * This method is therefore used to automatically disable platform features
     * that require are incompatible with seeAllData=true. For example: platform
     * cache is incompatible with seeAllData=true. However, our security
     * library, CanTheUser utilizes platform cache to accelerate Crud and FLS
     * checks. CanTheUser uses this method, in part, to determine, transparently
     * if it should utilize platformCache during test execution
     *
     * Note: It is not a good idea, and against best practices to use
     * seeAllData=true when not absolutely necessary.
     * @return      `Boolean`
     */
    @TestVisible
    private static Boolean isSeeAllDataTrue() {
        Boolean seeAllData = false;
        if (!Test.isRunningTest()) {
            return seeAllData; // This line is not testable :(
        }

        try {
            // this will throw an exception in a data-silo'd test.
            ConnectApi.ChatterUsers.getFollowings(
                null,
                String.valueOf(UserInfo.getUserId())
            );
            seeAllData = true;
        } catch (UnsupportedOperationException UE) {
            // this means seeAllData != true
            System.debug('Caught UnsupportedOperationException');
        }
        return seeAllData;
    }
}