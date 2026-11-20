package com.seckmet.jwtgmanager.security.infrastructure;

import com.seckmet.jwtgmanager.security.domain.User;
import com.seckmet.jwtgmanager.security.domain.UserRepository;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface UserJpaRepository extends JpaRepository<User, Long>, UserRepository {


    @Query("""
    select user from User user where user.email= :email
    """)
    User findByEmail(String email);

    @Override
    default User ofEmail(String email){
        return findByEmail(email);
    }

    @Override
    default User save(User user){
        return save(user);
    }
}

