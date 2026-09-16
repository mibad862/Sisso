import 'package:flutter/material.dart';
import 'package:flux_ui/flux_ui.dart';
import 'package:quiver/strings.dart';

import '../../../../common/constants.dart';

class Contact extends StatelessWidget {
  final Store store;

  const Contact({super.key, required this.store});

  Map<String, dynamic> get contactDetails {
    if (kHideStoreContactInfo) return {};

    var contacts = <String, dynamic>{};

    if (isNotBlank(store.address) && store.showAddress) {
      contacts['address'] = {
        'icon': Icons.place,
        'title': store.address,
        'url':
            'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(store.address!)}',
      };
    }

    if (isNotBlank(store.email) && store.showEmail) {
      contacts['email'] = {
        'icon': Icons.mail,
        'title': store.email,
        'url': 'mailto:${store.email}',
      };
    }

    final phone = store.phone?.toString() ?? '';
    if (isNotBlank(phone) && store.showPhone) {
      contacts['phone'] = {
        'icon': Icons.phone,
        'title': phone,
        'url': 'tel:$phone',
      };
    }

    final facebook = store.socials?['facebook']?.toString() ?? '';
    if (isNotBlank(facebook)) {
      contacts['facebook'] = {
        'icon': 'assets/icons/brands/facebook.svg',
        'color': '#1877F2',
        'title': facebook,
        'url': facebook,
      };
    }

    final twitter = store.socials?['twitter']?.toString() ?? '';

    if (isNotBlank(twitter)) {
      contacts['twitter'] = {
        'icon': 'assets/icons/brands/x.svg',
        'title': twitter,
        'url': twitter,
      };
    }

    final instagram = store.socials?['instagram']?.toString() ?? '';
    if (isNotBlank(instagram)) {
      contacts['instagram'] = {
        'icon': 'assets/icons/brands/instagram.svg',
        'color': '#E4405F',
        'title': instagram,
        'url': instagram,
      };
    }
    final linkedin = store.socials?['linkedin']?.toString() ?? '';
    if (isNotBlank(linkedin)) {
      contacts['linkedin'] = {
        'icon': 'assets/icons/brands/linkedin.svg',
        'color': '#0077B5',
        'title': linkedin,
        'url': linkedin,
      };
    }
    final telegram = store.socials?['telegram']?.toString() ?? '';
    if (isNotBlank(telegram)) {
      contacts['telegram'] = {
        'icon': 'assets/icons/brands/telegram.svg',
        'color': '#0088CC',
        'title': telegram,
        'url': telegram,
      };
    }
    final tiktok = store.socials?['tiktok']?.toString() ?? '';
    if (isNotBlank(tiktok)) {
      contacts['tiktok'] = {
        'icon': 'assets/icons/brands/tiktok.svg',
        'title': tiktok,
        'url': tiktok,
      };
    }
    final skype = store.socials?['skype']?.toString() ?? '';
    if (isNotBlank(skype)) {
      contacts['skype'] = {
        'icon': 'assets/icons/brands/skype.svg',
        'color': '#00AFF0',
        'title': skype,
        'url': 'skype:$skype?chat',
      };
    }
    final youtube = store.socials?['youtube']?.toString() ?? '';
    if (isNotBlank(youtube)) {
      contacts['youtube'] = {
        'icon': 'assets/icons/brands/youtube.svg',
        'color': '#FF0000',
        'title': youtube,
        'url': youtube,
      };
    }
    final flickr = store.socials?['flickr']?.toString() ?? '';
    if (isNotBlank(flickr)) {
      contacts['flickr'] = {
        'icon': 'assets/icons/brands/flickr.svg',
        'title': flickr,
        'url': flickr,
      };
    }
    final pinterest = store.socials?['pinterest']?.toString() ?? '';
    if (isNotBlank(pinterest)) {
      contacts['pinterest'] = {
        'icon': 'assets/icons/brands/pinterest.svg',
        'color': '#E60023',
        'title': pinterest,
        'url': pinterest,
      };
    }
    final threads = store.socials?['threads']?.toString() ?? '';
    if (isNotBlank(threads)) {
      contacts['threads'] = {
        'icon': 'assets/icons/brands/threads.svg',
        'title': threads,
        'url': threads,
      };
    }
    final github = store.socials?['github']?.toString() ?? '';
    if (isNotBlank(github)) {
      contacts['github'] = {
        'icon': 'assets/icons/brands/github.svg',
        'color': '#000000',
        'title': github,
        'url': (github.contains('http'))
            ? github
            : 'https://github.com/$github',
      };
    }
    final whatsapp = store.socials?['whatsapp']?.toString() ?? '';
    if (isNotBlank(whatsapp) || isNotBlank(phone)) {
      contacts['whatsapp'] = {
        'icon': 'assets/icons/brands/whatsapp.svg',
        'color': '#25D366',
        'title': whatsapp.isNotEmpty ? whatsapp : phone,
        'url': () {
          if (isNotBlank(whatsapp) && whatsapp.contains('http')) {
            return whatsapp;
          }
          final number = whatsapp.isNotEmpty ? whatsapp : phone;
          return 'https://wa.me/${number.replaceAll(RegExp(r'\D'), '')}';
        },
      };
    }
    final googleplus = store.socials?['googleplus']?.toString() ?? '';
    if (isNotBlank(googleplus)) {
      contacts['googleplus'] = {
        'icon': 'assets/icons/brands/google-plus.svg',
        'color': '#DB4437',
        'title': googleplus,
        'url': googleplus,
      };
    }

    final snapchat = store.socials?['snapchat']?.toString() ?? '';
    if (isNotBlank(snapchat)) {
      contacts['snapchat'] = {
        'icon': 'assets/icons/brands/snapchat.svg',
        'color': '#FFFC00',
        'title': snapchat,
        'url': snapchat,
      };
    }
    return contacts;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (final MapEntry(:value) in contactDetails.entries)
          ListTile(
            leading: _buildIcon(value['icon'], value['color']),
            title: Text(value['title']),
            onTap: () async {
              if (value.containsKey('url')) {
                await Tools.launchURL(value['url']);
              } else {
                await Tools.share(text: value['title'], context: context);
              }
            },
          ),
      ],
    );
  }

  Widget _buildIcon(dynamic icon, String? colorHex) {
    final color = colorHex?.toColor();

    if (icon is IconData) {
      return Icon(icon, color: color);
    }

    if (icon is String && icon.isNotEmpty) {
      return FluxImage(imageUrl: icon, width: 20, height: 20, color: color);
    }

    return Icon(Icons.link, color: color);
  }
}
