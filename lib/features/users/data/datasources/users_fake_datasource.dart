import 'dart:async';

import 'package:cactus_hr/core/core.dart';
import 'package:cactus_hr/features/general/general.dart';
import 'package:cactus_hr/features/users/users.dart';
import 'package:dartz/dartz.dart';

class UsersFakeDatasource implements UsersRemoteDatasource {
  const UsersFakeDatasource();

  static const List<DataUser> _mockUsers = [
    DataUser(
      id: '1',
      name: 'Azizbek Rahimov',
      email: 'azizbek.rahimov@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-03-01T10:00:00Z',
    ),
    DataUser(
      id: '2',
      name: 'Dilnoza Karimova',
      email: 'dilnoza.karimova@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-03-01T11:15:00Z',
    ),
    DataUser(
      id: '3',
      name: 'Jasur Aliyev',
      email: 'jasur.aliyev@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-28T16:20:00Z',
    ),
    DataUser(
      id: '4',
      name: 'Madina Umarova',
      email: 'madina.umarova@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-27T09:45:00Z',
    ),
    DataUser(
      id: '5',
      name: 'Sardorbek Qodirov',
      email: 'sardor.qodirov@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-26T14:10:00Z',
    ),
    DataUser(
      id: '6',
      name: 'Nodira Yusupova',
      email: 'nodira.yusupova@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-25T11:00:00Z',
    ),
    DataUser(
      id: '7',
      name: 'Bobur Mirzayev',
      email: 'bobur.mirzayev@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?auto=format&fit=crop&w=256&q=80',
      verified: false,
      updatedAt: '2026-02-24T17:30:00Z',
    ),
    DataUser(
      id: '8',
      name: 'Shahnoza Tursunova',
      email: 'shahnoza.tursunova@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-23T08:50:00Z',
    ),
    DataUser(
      id: '9',
      name: 'Ulugbek Normatov',
      email: 'ulugbek.normatov@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-22T13:40:00Z',
    ),
    DataUser(
      id: '10',
      name: 'Ziyoda Rustamova',
      email: 'ziyoda.rustamova@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-21T15:15:00Z',
    ),
    DataUser(
      id: '11',
      name: 'Bekzod Xolmatov',
      email: 'bekzod.xolmatov@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-20T12:00:00Z',
    ),
    DataUser(
      id: '12',
      name: 'Gulzoda Ismoilova',
      email: 'gulzoda.ismoilova@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1567532939604-b6b5b0db2604?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-19T10:30:00Z',
    ),
    DataUser(
      id: '13',
      name: 'Farrux Toirov',
      email: 'farrux.toirov@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=256&q=80',
      verified: false,
      updatedAt: '2026-02-18T16:45:00Z',
    ),
    DataUser(
      id: '14',
      name: 'Kamola Fayzullayeva',
      email: 'kamola.fayzullayeva@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-17T09:15:00Z',
    ),
    DataUser(
      id: '15',
      name: 'Otabek Salimov',
      email: 'otabek.salimov@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1501196354995-cbb51c65aaea?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-16T14:20:00Z',
    ),
    DataUser(
      id: '16',
      name: 'Rayhon Saidova',
      email: 'rayhon.saidova@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1548142813-c348350df52b?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-15T11:40:00Z',
    ),
    DataUser(
      id: '17',
      name: 'Temur Ahmedov',
      email: 'temur.ahmedov@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-14T15:00:00Z',
    ),
    DataUser(
      id: '18',
      name: 'Malika Sobirova',
      email: 'malika.sobirova@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=256&q=80',
      verified: false,
      updatedAt: '2026-02-13T10:10:00Z',
    ),
    DataUser(
      id: '19',
      name: "Sherzod Jo'rayev",
      email: 'sherzod.jorayev@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1513956589380-bad6acb9b9d4?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-12T16:00:00Z',
    ),
    DataUser(
      id: '20',
      name: 'Sevara Ergasheva',
      email: 'sevara.ergasheva@cactus.hr',
      photo: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=256&q=80',
      verified: true,
      updatedAt: '2026-02-11T08:30:00Z',
    ),
  ];

  static const int _pageSize = 10;

  @override
  Future<Either<Failure, UsersResponse>> users(UsersParams userParams) async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 500));

    final total = _mockUsers.length;
    final lastPage = (total / _pageSize).ceil();
    final startIndex = (userParams.page - 1) * _pageSize;

    if (startIndex >= total) {
      return const Right(
        UsersResponse(
          diagnostic: Diagnostic(status: '200', message: 'OK'),
          data: [],
          page: Page(
            currentPage: 1,
            perPage: _pageSize,
            lastPage: 1,
            total: 0,
          ),
        ),
      );
    }

    final endIndex = (startIndex + _pageSize).clamp(0, total);
    final pageUsers = _mockUsers.sublist(startIndex, endIndex);

    return Right(
      UsersResponse(
        diagnostic: const Diagnostic(status: '200', message: 'OK'),
        data: pageUsers,
        page: Page(
          currentPage: userParams.page,
          perPage: _pageSize,
          lastPage: lastPage,
          total: total,
        ),
      ),
    );
  }

  @override
  Future<Either<Failure, UserResponse>> user() async {
    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 300));

    return const Right(
      UserResponse(
        diagnostic: Diagnostic(status: '200', message: 'OK'),
        data: DataUser(
          id: 'admin_1',
          name: 'Azizbek Rahimov',
          email: 'azizbek.rahimov@cactus.hr',
          photo: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=256&q=80',
          verified: true,
          updatedAt: '2026-03-01T10:00:00Z',
        ),
      ),
    );
  }
}
