import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shakala/app_classes/current_workings.dart';
import 'package:shakala/app_classes/education.dart';
import 'package:shakala/app_classes/experience.dart';
import 'package:shakala/app_classes/skill.dart';
import 'package:shakala/app_classes/user.dart';
import 'package:shakala/pages/onboard_flow/welcome_page.dart';
import 'package:shakala/services/api_client.dart';
import 'package:shakala/sheets/create_moment_sheet.dart';
import 'package:shakala/sheets/my_account_edits/edit_about_sheet.dart';
import 'package:shakala/sheets/my_account_edits/edit_profile_details_sheet.dart';
import 'package:shakala/sheets/my_account_edits/show_current_workings_sheet.dart';
import 'package:shakala/sheets/my_account_edits/show_educations_sheet.dart';
import 'package:shakala/sheets/my_account_edits/show_experiences_sheet.dart';
import 'package:shakala/sheets/my_account_edits/show_skills_sheet.dart';

class ShowAccountPage extends StatefulWidget {
  final User? publicUser;

  const ShowAccountPage({
    super.key,
    this.publicUser
  });

  @override
  State<ShowAccountPage> createState() => _ShowAccountPageState();
}

class _ShowAccountPageState extends State<ShowAccountPage> {
  bool get publicUserMode => widget.publicUser != null;

  bool isLoadingUser = true;
  bool isLoadingFollows = true;
  bool isLoadingCurrentWorkings = true;
  bool isLoadingSkills = true;
  bool isLoadingExperiences = true;
  bool isLoadingEducations = true;
  bool isFollowing = false;
  bool isFollowLoading = false;

  User? user;
  int followersCount = 0;
  int followingCount = 0;
  List<CurrentWorking> currentWorkingsList = [];
  List<Skill> skillsList = [];
  List<Experience> experiencesList = [];
  List<Education> educationsList = [];

  @override
  void initState() {
    super.initState();
    checkFollowStatus();
    fetchFollows();
    fetchUser();
    fetchCurrentWorkings();
    fetchSkills();
    fetchExperiences();
    fetchEducations();
  }

  Future<void> checkFollowStatus() async {
    if (widget.publicUser == null) return;

    try {
      final currentUserId = await secureStorage.read(key: 'user_id');
      final apiClient = ApiClient();
      final response = await apiClient.get(
        '${ApiClient.baseBackendUrl}/users/$currentUserId/following/',
        auth: true,
      );
      final List followings = response['data'];

      setState(() {
        isFollowing = followings.any((u) => u['id'].toString() == widget.publicUser!.id);
      });
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> fetchFollows() async {
    final currentUserId = await secureStorage.read(key: 'user_id');
    String tmpUserId = widget.publicUser == null ? currentUserId! : widget.publicUser!.id!;

    setState(() {
      isLoadingFollows = true;
    });

    try {
      final apiClient = ApiClient();
      final response = await apiClient.get(
        '${ApiClient.baseBackendUrl}/users/$tmpUserId/followers/',
        auth: true,
      );
      final List followers = response['data'];

      setState(() {
        followersCount = followers.length;
      });

    } catch (e) {
      print('Error fetching followers count: $e');
    }

    try {
      final apiClient = ApiClient();
      final response = await apiClient.get(
        '${ApiClient.baseBackendUrl}/users/$tmpUserId/following/',
        auth: true,
      );
      final List followings = response['data'];

      setState(() {
        followingCount = followings.length;
      });

    } catch (e) {
      print('Error fetching following count: $e');
    }

    setState(() {
      isLoadingFollows = false;
    });
  }

  Future<void> fetchUser() async {
    final apiClient = ApiClient();
    final isOwnAccount = widget.publicUser == null;

    final url = isOwnAccount
        ? '${ApiClient.baseBackendUrl}/users/me/'
        : '${ApiClient.baseBackendUrl}/users/${widget.publicUser!.id}/';

    try {
      final response = await apiClient.get(url, auth: true);

      if (response != null && response is Map && response.containsKey('data')) {
        setState(() {
          user = User.fromJson(response['data']);
          isLoadingUser = false;
        });
      } else {
        setState(() => isLoadingUser = false);
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() => isLoadingUser = false);
    }
  }

  Future<void> fetchCurrentWorkings() async {
    final apiClient = ApiClient();
    final isOwnAccount = widget.publicUser == null;

    final url = isOwnAccount
        ? '${ApiClient.baseBackendUrl}/current_workings/user/'
        : '${ApiClient.baseBackendUrl}/current_workings/${widget.publicUser!.id}/';

    try {
      final response = await apiClient.get(url, auth: true);

      if (response != null &&
          response is Map &&
          response.containsKey('data') &&
          response['data'] is List) {
        setState(() {
          currentWorkingsList = (response['data'] as List)
              .map((item) => CurrentWorking.fromJson(item))
              .toList();
          isLoadingCurrentWorkings = false;
        });
      } else {
        setState(() => isLoadingCurrentWorkings = false);
      }
    } catch (e) {
      print('Error fetching current workings: $e');
      setState(() => isLoadingCurrentWorkings = false);
    }
  }

  Future<void> fetchSkills() async {
    final apiClient = ApiClient();
    final isOwnAccount = widget.publicUser == null;

    final url = isOwnAccount
        ? '${ApiClient.baseBackendUrl}/skills/user/'
        : '${ApiClient.baseBackendUrl}/skills/${widget.publicUser!.id}/';

    try {
      final response = await apiClient.get(url, auth: true);

      if (response != null &&
          response is Map &&
          response.containsKey('data') &&
          response['data'] is List) {
        setState(() {
          skillsList = (response['data'] as List)
              .map((item) => Skill.fromJson(item))
              .toList();
          isLoadingSkills = false;
        });
      } else {
        setState(() => isLoadingSkills = false);
      }
    } catch (e) {
      print('Error fetching skills: $e');
      setState(() => isLoadingSkills = false);
    }
  }

  Future<void> fetchExperiences() async {
    final apiClient = ApiClient();
    final isOwnAccount = widget.publicUser == null;

    final url = isOwnAccount
        ? '${ApiClient.baseBackendUrl}/experiences/user/'
        : '${ApiClient.baseBackendUrl}/experiences/${widget.publicUser!.id}/';

    try {
      final response = await apiClient.get(url, auth: true);

      if (response != null &&
          response is Map &&
          response.containsKey('data') &&
          response['data'] is List) {
        setState(() {
          experiencesList = (response['data'] as List)
              .map((item) => Experience.fromJson(item))
              .toList();
          isLoadingExperiences = false;
        });
      } else {
        setState(() => isLoadingExperiences = false);
      }
    } catch (e) {
      print("Error fetching experiences: $e");
      setState(() => isLoadingExperiences = false);
    }
  }

  Future<void> fetchEducations() async {
    final apiClient = ApiClient();
    final isOwnAccount = widget.publicUser == null;

    final url = isOwnAccount
        ? '${ApiClient.baseBackendUrl}/educations/user/'
        : '${ApiClient.baseBackendUrl}/educations/${widget.publicUser!.id}/';

    try {
      final response = await apiClient.get(url, auth: true);

      if (response != null &&
          response is Map &&
          response.containsKey('data') &&
          response['data'] is List) {
        setState(() {
          educationsList = (response['data'] as List)
              .map((item) => Education.fromJson(item))
              .toList();
          isLoadingEducations = false;
        });
      } else {
        setState(() => isLoadingEducations = false);
      }
    } catch (e) {
      print("Error fetching educations: $e");
      setState(() => isLoadingEducations = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Shakala Card
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: isLoadingUser
                  ? const Center(child: CircularProgressIndicator())
                  : user == null
                  ? const Center(child: Text("Failed to load user data."))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        // height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            stops: [0.3, 0.8],
                            colors: [Color(0xFFa393eb), Color(0xFF7e68e3)],
                          ),
                        ),
                        child: Row(
                          children: [
                            // Profile Image
                            Padding(
                              padding: EdgeInsets.only(left: 10.0),
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(20.0,),
                                child: user!.profileImage == null
                                  ? Image.asset(
                                      'assets/images/empty_dp.png',
                                      width: 130,
                                      height: 130,
                                      fit: BoxFit.cover,
                                    )
                                  : user!.profileImage!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: '${ApiClient.baseBackendUrl}${user!.profileImage!}',
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(
                                            width: 130,
                                            height: 130,
                                            alignment: Alignment.center,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          ),
                                          errorWidget: (context, url, error) => Image.asset(
                                            'assets/images/empty_dp.png',
                                            width: 130,
                                            height: 130,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          'assets/images/empty_dp.png',
                                          width: 130,
                                          height: 130,
                                          fit: BoxFit.cover,
                                        ),
                              ),
                            ),

                            // Profile Details
                            Expanded(
                              child: Container(
                                height: 150,
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Stack(
                                  children: [
                                    // Name and Bio
                                    SizedBox(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            (user?.name ?? "").length > 25
                                              ? '${(user!.name!).substring(0, 25)}...'
                                              : (user?.name ?? ""),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                              height: 1.0,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                          ),
                                          SizedBox(height: 4,),
                                          Text(
                                            (user?.headline ?? "").length > 50
                                              ? '${(user!.headline!).substring(0, 50)}...'
                                              : (user?.headline ?? ""),
                                            style: TextStyle(
                                              color: Colors.grey.shade300,
                                              fontSize: 14,
                                              height: 1.0,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Edit Icons
                                    publicUserMode
                                      ? Container()
                                      : Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  _showEditProfileDetailsSheet(context, user?.name ?? '', user?.headline ?? '', user?.profileImage ?? '');
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  color: Colors.black,
                                                  size: 18,
                                                ),
                                              ),
                                              // Icon(Icons.share, size: 18),
                                            ],
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),

            // Follow Button
            publicUserMode
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isFollowLoading ? null : _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing 
                          ? Colors.grey.withOpacity(0.2) 
                          : Color(0xffa393eb),
                        foregroundColor: isFollowing ? Colors.grey : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isFollowing ? Colors.grey : Colors.transparent,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: isFollowLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: isFollowing ? Colors.grey : Colors.white,
                              ),
                            )
                          : Text(
                              isFollowing ? 'Following' : 'Follow',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                )
              : SizedBox(height: 16),
            
            // Empty profile message
            publicUserMode && ((user?.about?.trim().isEmpty ?? true) && currentWorkingsList.isEmpty)
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0x119E9E9E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The user hasn\'t added any details yet.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox.shrink(),

            // Followers and Following Count
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20),
              child: isLoadingFollows
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              followersCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              "Followers",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              followingCount.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 20,
                                height: 1.2,
                              ),
                            ),
                            Text(
                              "Following",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
              )
            ),

            // About Section
            (!publicUserMode || (publicUserMode && (user?.about?.trim().isNotEmpty ?? false)))
              ? _buildSection(
                  title: 'About',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.about ?? 'No about added.',
                        style: TextStyle(
                          color: Colors.grey.shade300,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                  onEdit: publicUserMode
                    ? null
                    : () => _showEditAboutSheet(context, user?.about ?? ''),
                )
              : SizedBox.shrink(),

            // Current Workings
            (!publicUserMode || (publicUserMode && (currentWorkingsList.isNotEmpty)))
              ? _buildSection(
                  title: 'Currently Working On',
                  child: isLoadingCurrentWorkings
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : currentWorkingsList.isEmpty
                          ? Text(
                              'No current workings added.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: currentWorkingsList
                                  .map((working) => Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      working.title,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      working.description,
                                                      style: TextStyle(
                                                        color: Colors.grey.shade400,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                _formatDateDateMonth(working.createdAt!),
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                  onEdit: publicUserMode
                    ? null
                    : () => _showShowCurrentWorkingsSheet(context, currentWorkingsList),
                )
              : SizedBox.shrink(),

            // Skills
            (!publicUserMode || (publicUserMode && (skillsList.isNotEmpty)))
              ? _buildSection(
                  title: 'Skills',
                  child: isLoadingSkills
                      ? const Center(child: CircularProgressIndicator())
                      : skillsList.isEmpty
                          ? Text(
                              'No skills added.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            )
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: skillsList.map((skill) => Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color(0x33a393eb),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Color(0x66a393eb),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        skill.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                        softWrap: true,
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      toCapitalCase(skill.level),
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              )).toList(),
                            ),
                  onEdit: publicUserMode
                    ? null
                    : () => _showShowSkillsSheet(context, skillsList),
                )
              : SizedBox.shrink(),

            // Experiences
            (!publicUserMode || (publicUserMode && (experiencesList.isNotEmpty)))
              ? _buildSection(
                  title: 'Experiences',
                  child: isLoadingExperiences
                      ? const Center(child: CircularProgressIndicator())
                      : experiencesList.isEmpty
                          ? Text(
                              'No experiences added.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            )
                          : Column(
                              children: experiencesList
                                  .map((experience) => Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                experience.title,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                experience.companyName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${_formatDateMonthYear(DateTime.parse(experience.startDate))} - ${experience.endDate == 'Present' ? 'Present' : _formatDateMonthYear(DateTime.parse(experience.endDate))}',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    experience.cityOrOnline == "<ONLINE>"
                                                    ? 'Remote Opportunity'
                                                    : _formatLocationAll(
                                                      experience.cityOrOnline,
                                                      experience.state,
                                                      experience.country,
                                                    ),
                                                    style: TextStyle(
                                                      color: Colors.grey.shade500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                  onEdit: publicUserMode
                    ? null
                    : () => _showShowExperiencesSheet(context, experiencesList),
                )
              : SizedBox.shrink(),

            // Education
            (!publicUserMode || (publicUserMode && (educationsList.isNotEmpty)))
              ? _buildSection(
                  title: 'Education',
                  child: isLoadingEducations
                      ? const Center(child: CircularProgressIndicator())
                      : educationsList.isEmpty
                          ? Text(
                              'No educations added.',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            )
                          : Column(
                              children: educationsList
                                  .map((education) => Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: Container(
                                          padding: EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.08),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                education.school.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                education.degree.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    '${_formatDateMonthYear(DateTime.parse(education.startDate))} - Present',
                                                    style: TextStyle(
                                                      color: Colors.grey.shade500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                education.fieldOfStudy.name,
                                                style: TextStyle(
                                                  color: Colors.grey.shade500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                  onEdit: publicUserMode
                    ? null
                    : () => _showShowEducationsSheet(context, educationsList),
                )
              : SizedBox.shrink(),

            // Logout Button
            !publicUserMode
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: Colors.grey[900],
                            title: Text('Confirm Logout', style: TextStyle(color: Colors.white)),
                            content: Text('Are you sure you want to log out?', style: TextStyle(color: Colors.grey)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text('Logout', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );

                        if (shouldLogout == true) {
                          await secureStorage.deleteAll();

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => WelcomePage()),
                            (Route<dynamic> route) => false,
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color.fromARGB(255, 255, 101, 101),
                        side: BorderSide(
                          color: Color.fromARGB(255, 255, 101, 101), 
                          width: 1.5
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent sections
  Widget _buildSection({
    required String title,
    required Widget child,
    VoidCallback? onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit, color: Colors.grey.shade400, size: 20),
                ),
            ],
          ),
          SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: child,
          ),
        ],
      ),
    );
  }
  Future<void> _toggleFollow() async {
    if (widget.publicUser == null) return;

    setState(() {
      isFollowLoading = true;
    });

    try {
      final apiClient = ApiClient();
      final endpoint = isFollowing ? 'unfollow' : 'follow';
      await apiClient.post(
        '${ApiClient.baseBackendUrl}/users/$endpoint/',
        'json',
        {'followee': widget.publicUser!.id},
        auth: true,
      );

      setState(() {
        isFollowing = !isFollowing;
      });
    } catch (e) {
      print('Follow/unfollow error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong.')),
      );
    } finally {
      setState(() {
        isFollowLoading = false;
      });
    }
  }

  String toCapitalCase(String input) {
    return input
        .toLowerCase()
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  void _showEditProfileDetailsSheet(BuildContext context, String name, String headline, String profileImage) async {
    final shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditProfileDetailsSheet(name: name, headline: headline, profileImage: profileImage),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
    if (shouldRefresh == true) {
      fetchUser();
    }
  }

  void _showEditAboutSheet(BuildContext context, String about) async {
    final shouldRefresh = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => EditAboutSheet(about: about,),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
    if (shouldRefresh == true) {
      fetchUser();
    }
  }

  void _showShowCurrentWorkingsSheet(BuildContext context, List<CurrentWorking> currentWorkingsList) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShowCurrentWorkingsSheet(onUpdated: fetchCurrentWorkings, currentWorkingsList: currentWorkingsList),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  void _showShowSkillsSheet(BuildContext context, List<Skill> skillsList) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShowSkillsSheet(onUpdated: fetchSkills, skillsList: skillsList,),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  void _showShowExperiencesSheet(BuildContext context, List<Experience> experiencesList) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShowExperiencesSheet(onUpdated: fetchExperiences, experiencesList: experiencesList,),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  void _showShowEducationsSheet(BuildContext context, List<Education> educationsList) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShowEducationsSheet(onUpdated: fetchEducations, educationsList: educationsList,),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

  String _formatDateDateMonth(DateTime date) {
    final now = DateTime.now();
    final isSameYear = date.year == now.year;

    if (isSameYear) {
      return DateFormat("d MMM").format(date); // e.g., "27 Mar"
    } else {
      return DateFormat("d MMM ''yy").format(date); // e.g., "27 Mar '22"
    }
  }

  String _formatDateMonthYear(DateTime date) {
    // Example: Aug 2023
    return DateFormat.yMMM().format(date);
  }

  String _formatLocationAll(String? cityOrOnline, String? state, String? country) {
    final parts = [cityOrOnline, state, country]
        .where((e) => e != null && e.trim().isNotEmpty)
        .toList();
    return parts.isEmpty ? '' : parts.join(', ');
  }

}
